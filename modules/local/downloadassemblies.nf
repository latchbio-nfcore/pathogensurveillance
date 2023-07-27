process DOWNLOAD_ASSEMBLIES {                                                  
    tag "$id"                                                              
    label 'process_single'
    maxForks 1                                                      
                                                                                
    conda "conda-forge::ncbi-datasets-cli=15.11.0"                                
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-datasets-cli:14.26.0 ':
        'quay.io/biocontainers/ncbi-datasets-cli:14.26.0' }"               
                                                                                
    input:                                                                      
    val id // There is no meta because we want to cache based only the ID                                                                
                                                                                
    output:                                                                     
    tuple val(id), path("${prefix}.zip"), emit: assembly                             
    path "versions.yml"                 , emit: versions                             
                                                                                
    when:                                                                       
    task.ext.when == null || task.ext.when                                      
                                                                                
    script:                                                                     
    prefix = task.ext.prefix ?: "${id}".replaceAll(' ', '_')                               
    def args = task.ext.args ?: ''                                              
    """
    datasets download genome accession $id --include gff3,rna,cds,protein,genome,seq-report --filename ${prefix}.zip
 
    cat <<-END_VERSIONS > versions.yml                                          
    "${task.process}":                                                          
        datasets: \$(datasets --version | sed -e "s/datasets version: //")                                           
    END_VERSIONS                                                                
    """                                                                         
}
