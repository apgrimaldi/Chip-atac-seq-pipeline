process DEEPTOOLS {
    tag "$meta.id"
    label 'process_high' // DeepTools (soprattutto computeMatrix) mangia molta RAM
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    
    publishDir "${params.outdir}/07_advanced_qc", mode: 'copy'

    input:
    tuple val(meta), path(bam), path(bai)
    path  genes_bed // Il file con le coordinate dei geni (es. hg38_genes.bed)

    output:
    path "*.fingerprint.pdf"    , emit: fingerprint_pdf
    path "*.fingerprint.txt"    , emit: fingerprint_txt // Fondamentale per MultiQC
    path "*.bigWig"             , emit: bw
    path "*.profile.pdf"        , emit: profile_pdf
    path "*.profile.data.gz"    , emit: profile_data
    path "versions.yml"         , emit: versions

    script:
    def prefix = "${meta.id}"
    """
    # 1. Genera BigWig (Normalizzato CPM per confrontare campioni diversi)
    bamCoverage -b $bam -o ${prefix}.bigWig --binSize 10 --normalizeUsing CPM --numberOfProcessors $task.cpus

    # 2. Fingerprint (Qualità dell'arricchimento)
    plotFingerprint -b $bam --plotFile ${prefix}.fingerprint.pdf --outRawCounts ${prefix}.fingerprint.txt --numberOfProcessors $task.cpus --skipZeros

    # 3. Compute Matrix (Prepara i dati per il profilo sui TSS)
    # Usiamo 'reference-point' centrato sul TSS
    computeMatrix reference-point \\
        --referencePoint TSS \\
        -b 2000 -a 2000 \\
        -R $genes_bed \\
        -S ${prefix}.bigWig \\
        -o ${prefix}.matrix.gz \\
        --numberOfProcessors $task.cpus

    # 4. Plot Profile (Il grafico finale a "montagnetta")
    plotProfile -m ${prefix}.matrix.gz \\
        -out ${prefix}.profile.pdf \\
        --outFileNameData ${prefix}.profile.data.gz \\
        --plotTitle "${prefix} TSS Profile"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(deetools --version | cut -d' ' -f2)
    END_VERSIONS
    """
}
