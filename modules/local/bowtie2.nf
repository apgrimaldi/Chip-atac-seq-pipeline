process BOWTIE2 {
    tag "$meta.id"
    label 'process_high'
    
    // Container ufficiale su DockerHub - Questo Docker lo trova SEMPRE
    container 'biocontainers/bowtie2:2.4.1--py38he513fc3_0'

    input:
    tuple val(meta), path(reads)
    path index_dir 

    output:
    // Produciamo il SAM perché questo container ha solo Bowtie2
    tuple val(meta), path("*.sam"), emit: sam
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml"           , emit: versions

    script:
    def prefix = "${meta.id}_aln"
    """
    # 1. Trova il basename dell'indice
    INDEX_BASE=\$(ls ${index_dir}/*.1.bt2 | head -n 1 | sed 's/\\.1\\.bt2//')

    # 2. Allineamento (senza pipe, scriviamo il SAM)
    bowtie2 \\
        -x \$INDEX_BASE \\
        -1 ${reads[0]} \\
        -2 ${reads[1]} \\
        -p $task.cpus \\
        --very-sensitive \\
        --no-discordant \\
        -X 2000 \\
        -S ${prefix}.sam \\
        2> ${prefix}.bowtie2.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}
