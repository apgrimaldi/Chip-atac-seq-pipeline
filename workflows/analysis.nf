// 1. Importazione dei moduli
include { FASTQC }         from '../modules/local/fastqc.nf'
include { TRIMGALORE }     from '../modules/local/trimgalore.nf'
include { BOWTIE2 }        from '../modules/local/bowtie2.nf'
include { SAMTOOLS_SORT }  from '../modules/local/samtools_sort.nf'

workflow ATAC_CHIP_PIPELINE {
    take:
    ch_input    // Canale con le reads (meta, [r1, r2])
    ch_index    // Canale con l'indice del genoma

    main:
    ch_versions = Channel.empty()

    // 1. Controllo Qualità iniziale
    FASTQC ( ch_input )
    ch_versions = ch_versions.mix(FASTQC.out.versions)

    // 2. Pulizia reads (Trimming)
    TRIMGALORE ( ch_input )
    ch_versions = ch_versions.mix(TRIMGALORE.out.versions)

    // 3. Allineamento con Bowtie2
    // NOTA: Abbiamo modificato il modulo per emettere 'sam' (per stabilità Docker)
    BOWTIE2 ( TRIMGALORE.out.reads, ch_index )
    ch_versions = ch_versions.mix(BOWTIE2.out.versions)

    // 4. Ordinamento e indicizzazione
    // MODIFICATO: Usiamo .out.sam perché è quello che Bowtie2 emette ora
    SAMTOOLS_SORT ( BOWTIE2.out.sam )
    ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions)

    emit:
    bam      = SAMTOOLS_SORT.out.bam
    bai      = SAMTOOLS_SORT.out.bai
    versions = ch_versions
}
