# Rare Disease Analyser

The Rare Disease Analyzer (RDA) is a user-friendly webapp that provides statistical methods for longitudinal data with a limited number of subjects. Data with these characteristics is encountered in studies on rare diseases, hence the name of the app. It is developed in the course of the [EBStatMax project](https://www.ejprarediseases.org/funded-projects-demonstration-2/), which is a demo project funded by the European Joint Program on Rare Diseases.

The RDA is developed with `R shiny`, a standalone webframework in the `R` programming language ecosystem. Development is still in an early stage, i.e., the set of implemented statistical methods will grow larger with time. At this stage, no user documentation is available, as no official release has been announced yet.

## Install and Run with Docker (recommended)

Assuming you have docker installed on your Linux system, open a terminal, navigate to the repo root, and build an image from the provided Dockerfile with:

`sudo docker image build -t rare-disease-analyser .`

Hence, the created image is tagged `rare-disease-analyser`. To run a new container from this image, type:

`sudo docker run --rm -p 3838:3838 rare-disease-analyser:latest`

The `p` option manages the container's published ports. The integer ahead of the colon determines the host port. I.e., we can now access the rare disease analyser at `http://127.0.0.1:3838`.

## Install and Run locally

You need an installation of `R` version `4.1.2` (other not too old versions will probably work too), which is available for multiple operating systems. Instructions can be found [here](https://cran.r-project.org/).

Once the `R` interpreter is setup, install the following packages with `R`'s built-in package manager. On Linux systems this works as follows:

Open a terminal and type `R`. This should start an interactive session with the interpreter.

Type `install.packages("devtools")`. This enables one to install specific package versions in the following step.

Type `library(devtools)` to attach the namespace of the previously installed package. You can now directly call the `install_version` function. Do this for the following packages and versions:

- `install_version("shiny", "1.7.1")`
- `install_version("shinyjs", "2.1.0")`
- `install_version("DT", "0.21")`
- `install_version("nparLD", "2.1")`

Note: depending on your system, you might need to install some additional dependencies. Watch out for error messages when installing the above packages.

If everything went fine you are now ready to go. Open a terminal, navigate to the repo root directory, and type:

`R -e 'shiny::runApp("./")'`

This starts the shiny webserver, which is listening (as displayed) at `localhost` on port `3838`.
