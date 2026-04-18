process FILTERING {
    tag "$meta.id"
    label 'process_medium'
    
    // Questo container contiene bedtools, necessario per l'intersect
    container 'quay.io/biocontainers/bedtools:2.30.0--hc088bd4_0'

    publishDir "${params.outdir}/04_filtered", mode: 'copy'

    input:
    tuple val(meta), path(bam)
    path  blacklist

    output:
    tuple val(meta), path("*.filtered.bam"), emit: bam
    path "versions.yml"                    , emit: versions

    script:
    def prefix = "${meta.id}"
    """
    # 1. Gestione Blacklist 
    if [[ "$blacklist" == *.gz ]]; then
        gunzip -c "$blacklist" > actual_blacklist.bed
    else
        cp "$blacklist" actual_blacklist.bed
    fi

    # 2. Rimozione Blacklist
    # -v (invert match): scrive solo le reads che NON intersecano la blacklist
    # -abam: specifica che l'input A è un file BAM
    bedtools intersect -v -abam $bam -b actual_blacklist.bed > ${prefix}.filtered.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed 's/bedtools v//')
    END_VERSIONS
    """
}
