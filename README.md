# Rare Disease Analyser

The Rare Disease Analyzer (RDA) is a `R shiny` webapp that provides statistical methods for longitudinal data with a limited number of subjects. Data with these characteristics is encountered in studies on rare diseases, hence the name of the app. Currently, the set of statistical methods comprises of `nparLD` and selected `GPC` variants.

The RDA was developed in the EBStatMax project, a demo project funded by the [European Joint Program on Rare Diseases](https://www.ejprarediseases.org/).

## Usage 

Users upload their tabular dataset (`.csv` or `.txt`), which is then processed by the RDA.
The RDA provides a graphical user interface to select the statistical method and the parameters for the analysis.
The parameters include the statistical model, i.e., the names of the variables in the dataset and their role in the model.
Importantly, the RDA provides a preview of the data, which is useful to check if the data was uploaded correctly.
The results are displayed in tables and plots, depending on the selected method.
Note that in addition to data from studies with a single treatment period, the RDA is capable of handling data from cross over studies, i.e., studies with two treatment periods.
A detailed user manual (`app/www/RDA User Manual.pdf`) is available in the RDA.


## Install and Run

### with Docker (recommended)

Assuming you have docker installed on your Linux system, open a terminal, navigate to the repo root, and build an image from the provided Docker file with:
`sudo docker image build -t rare-disease-analyser .`

To run a new container from this image, type:
`sudo docker run --rm -p 3838:3838 rare-disease-analyser:latest`

The `p` option manages the container's published ports. The integer ahead of the colon determines the host port. I.e., we can now access the rare disease analyser at `http://127.0.0.1:3838`.

### locally

Install `R 4.2.1`, which is available for multiple operating systems. Instructions can be found [here](https://cran.r-project.org/).

Once the `R` interpreter is setup, install the following packages with `R`'s built-in package manager. On Linux systems this works as follows:

Open a terminal and type `R` to start an interactive session with the interpreter.

Type `install.packages("devtools")`. This enables one to install specific package versions in the following step.

Type `library(devtools)` to attach the namespace of the previously installed package. You can now directly call the `install_version` function. Do this for the following packages and versions:

    install_version("shiny", "1.7.1")
    install_version("shinyjs", "2.1.0")
    install_version("shinybusy", "0.3.1")
    install_version("DT", "0.21")
    install_version("nparLD", "2.2")
    install_version("BuyseTest", "2.3.11")
    install_version("pbapply", "1.5-0")  # BuyseTest requirement

Note that depending on your system, you might need to install some additional dependencies. Watch out for error messages when installing the above packages.

If everything went fine you are now ready to go. Open a terminal, navigate to the repo root directory, and type:

`R -e 'shiny::runApp("./app")'`

This starts the shiny webserver, which is listening (as displayed) at `localhost` on port `3838`.
