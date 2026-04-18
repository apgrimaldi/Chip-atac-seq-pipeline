process FASTQC {
    tag "${meta.id}"
    label 'process_low'

    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'
    
    // Nota: Il publishDir lo abbiamo già definito nel nextflow.config, 
    // quindi qui potresti anche toglierlo per non creare conflitti, 
    // ma lasciarlo non rompe nulla.
    publishDir "${params.outdir}/01_fastqc", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions

    script:
    // Usiamo -t per sfruttare i core assegnati nel config
    """
    fastqc -t $task.cpus -q $reads
    
    cat <<EOF > versions.yml
    "${task.process}":
        fastqc: \$(fastqc --version | sed 's/FastQC v//')
    EOF
    """
}
