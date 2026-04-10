process FASTQC {
    tag "${meta.id}"
    label 'process_low'
    
    // Usiamo quay.io che è lo standard di nf-core, più stabile di DockerHub
    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'
    
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions

    script:
    """
    fastqc $reads
    
    cat <<EOF > versions.yml
    "${task.process}":
        fastqc: \$(fastqc --version | sed 's/FastQC v//')
    EOF
    """
}
