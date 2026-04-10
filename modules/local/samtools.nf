process SAMTOOLS_SORT {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}/bams", mode: 'copy'

    // Usiamo DockerHub per evitare errori di permessi su Quay.io
    container 'biocontainers/samtools:v1.9-4-deb_cv1'

    input:
    // Riceve il file .sam dal modulo Bowtie2
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("*.sorted.bam")     , emit: bam
    tuple val(meta), path("*.sorted.bam.bai") , emit: bai 
    path "versions.yml"                       , emit: versions

    script:
    def prefix = "${meta.id}"
    """
    # 1. Converte SAM in BAM, ordina e salva in un colpo solo
    # Usiamo -@ $task.cpus per usare tutta la potenza che abbiamo dato nel config
    samtools sort -@ $task.cpus -o ${prefix}.sorted.bam $sam
    
    # 2. Crea l'indice del file BAM (genera il file .bai)
    samtools index -@ $task.cpus ${prefix}.sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/ .*\$//')
    END_VERSIONS
    """
}
