# Snakefile
# File contianing Pipeline to analyze single peaks of pure?clip clip seqeuencing

# usage something like:
#```{bash}
# snakemake -c[number of cores] --use-conda --config input=[input path to .bad files folder] # this i would like to change since its ugly ass shit
# ```

# CROSS-LINKING idea -> move to README
# PureCLIP looks for the "exact start " position of the reads to map the binding site
# since cross-linking can occur anywhere the protein contacts the RNA, the "size" of the binding site is the genomic interval where cross-link evcents are significantly higher than the background "noise" of random collisions.

#1) to infer the size of the binding: uses KERNEL DENSITY ESTIMTION (a non-parametric method to estimate the probability density function of a random variable)
# the ide ais to exploita Gaussian curbve over every single-nucleotide cross-link site (SNCLS) that defines a "landscape" distribution
# since the computatioion of KDE might take a while thinking of switching to something more computational pragmatic/easier to parallelize suhc as C or RUst
#2) inferred the binding site size we need to pass to the statistical validation of each peak found. 
# using a Permutation Test (NUll Model) -> considering the interval of confidence of 95% of the peak, generate Null Distribution with shuffles and the things u usually do, and calculate the p-value on the same positionby chance
#2.1) could alsto analyze the entropy of the peak size as a validation method
# probabily using the nurmnal kernel for the KDE
#  where teta is the standard normal density function. The kernel density estimator then becomes

# {\displaystyle {\hat {f}}_{h}(x)={\frac {1}{n}}\sum _{i=1}^{n}{\frac {1}{h{\sqrt {2\pi }}}}\exp \left({\frac {-(x-x_{i})^{2}}{2h^{2}}}\right),}

# to add in the conda environemnt pureclip


# Pipeline takes in input a folder with series of .bad files 
# snakemake --dag | dot -Tsvg > pipeline_dag.svg

# Load configuration
configfile: "config.yml"
import os

# --- Configuration Logic ---
DO_BACKUP = config.get("backup", False) # RUN also a backup rule after the workflow ended -> probabily gonna remove it
IS_PLANE = config.get("plane", False)
KEEP_JUNK = config.get("keep_junk", False) # run if u want to keep intermediate results

# functional option -> here is to add he actual return values
standard_targets = ["basic", "report?"]
if not IS_PLANE:
    standard_targets.append("other")


# --- Handlers for Automatic Cleanup ---

# add handlers for KEEP_JUNK execution
onsuccess:
    if os.path.exists(".tmp/setup_complete.txt"):
        os.remove(".tmp/setup_complete.txt")
    print("Workflow finished successfully. Cleanup complete.")

onerror:
    if os.path.exists(".tmp/setup_complete.txt"):
        os.remove(".tmp/setup_complete.txt")
    print("Workflow failed. Cleanup complete.")

# --- Workflow Rules ---

rule all:
    input:
        standard_targets
        
rule preprep:
    output:
        temp(".tmp/setup_complete.txt")
    shell:
        """
        GREEN='\033[38;2;46;139;87m'
        RESET='\033[0m'

        echo -e "${{GREEN}}"
        cat << "EOF"
██████╗ ███╗   ██╗ ███████████╗      ██████╗ 
██╔══██╗████╗  ██║██╔══██╔════╝      ██╔══██╗
██████╔╝██╔██╗ ██║█████████╗   █████╗██████╔╝
██╔══██╗██║╚██╗██║██╔══███╔╝   ╚════╝██╔═══╝ 
██║  ██║██║ ╚████║██║  ███████╗      ██║     
╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚══════╝      ╚═╝
EOF
        echo -e "${{RESET}}"
        
# here ADD ADDITIONAL CHECK for GITTOKEN and DATABASES (if needed) and other stuff that is needed for the pipeline to run correctly, if not present exit with an error message

        mkdir -p log
        mkdir -p results
        mkdir -p .tmp
        echo "Setup complete." > {output}
        """

# rule check:
#     input:
#         bins = "data/mags/"
#     output:
#         flag = ".tmp/checked.txt",
#         files = expand("data/mags/{sample}.fna", sample=SAMPLES)
#     run:
#         import os
#         import bz2
#         # Check if files are correctly present in the data/mags/ directory
#         if not os.path.exists(input.bins):
#             raise FileNotFoundError(f"Input bins not found at {input.bins}")
        
#         # Get the list of files in the mags directory
#         for file in os.listdir(input.bins):
#             if os.path.isfile(os.path.join(input.bins, file)):
#                 # Remove file extension to get sample name (not sure its the best approach but it works for now)
#                 sample_name = os.path.splitext(os.path.splitext(file)[0])[0]
#                 # sample_name = os.path.splitext(sample_name)[0]
#                 files_in_dir.add(sample_name)
        
#         # Compare with SAMPLES list
#         samples_set = set(SAMPLES)

# # ------DEBUG PRINTS --------
#         # print(f"Files in directory: {files_in_dir}")
#         # print(f"Expected samples: {samples_set}")

#         missing_samples = samples_set - files_in_dir
#         extra_files = files_in_dir - samples_set
       
#         if missing_samples:
#             raise ValueError(f"Missing samples in data/mags/: {missing_samples}")
        
#         if extra_files:
#             raise ValueError(f"Extra unexpected files in data/mags/: {extra_files}")
        
#         # All checks passed
#         with open(output.flag, 'w') as f:
#             f.write("All file names match SAMPLES list. Bins are present and ready for analysis.\n")

#         # Check the unzipping of the files is terminated without any error
    
#         # Find and extract all zip files
#         print("Checking for bz2 files to extract...")
#         for filename in os.listdir(input.bins):
#             filepath = os.path.join(input.bins, filename)
#             newfilepath = os.path.join(input.bins, os.path.splitext(filename)[0])  # Remove .bz2 extension (maybe there is a prettier way to do that)
#             with open(newfilepath, 'wb') as new_file, bz2.BZ2File(filepath, 'rb') as file:
#                 for data in iter(lambda : file.read(100 * 1024), b''):
#                     new_file.write(data)
#         # Create flag file
#         with open(output.flag, 'a') as f:
#             f.write("All bz2 files have been extracted.\n")

# Saves all the results and logs in a backup folder. prepared to be cleaned and runned again
rule backup:
    shell: 
        """
        # SAVE CURRENT TIME
        TIME=$(date +%Y-%m-%d_%H-%M-%S)
        # CREATE A BACKUP OF THE RESULTS AND LOGS in BACKUP FOLDER
        mkdir -p backup
        tar -czvf backup/backup_${{TIME}}.tar.gz results/ log/
        """

## Visual Difference
# ```
# RULE (static):
#   Start → Build full DAG → Run A → Run B → Run C → Done
#           [everything known]

# CHECKPOINT (dynamic):
#   Start → Build partial DAG → Run A → STOP → Rebuild DAG → Run B → Run C → Done
#                                        [inspect outputs]
#  ```