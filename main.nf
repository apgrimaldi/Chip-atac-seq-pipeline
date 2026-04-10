nextflow.enable.dsl=2

// Importa il workflow principale
include { ATAC_CHIP_PIPELINE } from './workflows/analysis.nf'

workflow {
    // 1. Canale per i file FASTQ (Input)
    ch_input = Channel
        .fromFilePairs(params.input, checkIfExists: true)
        .map { name, files -> [ [id:name], files ] }

    // 2. Logica Indice: Priorità al locale (veloce), poi iGenomes (lento)
    // Se l'utente scrive --bowtie2_index nel comando, usiamo quello.
    // Altrimenti lo cerchiamo in igenomes.config
    def index_path = params.bowtie2_index ?: params.genomes[ params.genome ]?.bowtie2 ?: null

    if (!index_path) {
        error "Errore: Non trovo l'indice! Usa --genome o specifica --bowtie2_index"
    }

    // Creiamo il canale per l'indice
    // Rimuoviamo 'checkIfExists: true' per i percorsi S3, così Nextflow non si blocca a controllare
    ch_index = Channel.value(file(index_path, type: 'dir'))

    // 3. Lanciamo il workflow
    ATAC_CHIP_PIPELINE ( ch_input, ch_index )
}
