
# get ubuntu 20.04 (focal) with R=4.1.2 installed
FROM rocker/r-ver:4.1.2

# install system dependencies
RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev \
        libxt6

# install R devtools in order to install specific package versions later
RUN R -e 'install.packages("devtools")'

# install packages
RUN R -e 'library(devtools); \
    install_version("shiny", "1.7.1"); \
    install_version("shinyjs", "2.1.0"); \
    install_version("DT", "0.21"); \
    install_version("nparLD", "2.1");'

# switch to non-root user (non-daemon users usually start at 1000)
ARG USERNAME=shiny-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# create non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME  
USER $USERNAME

# copy sources and change directory
COPY ./app /home/$USERNAME/app
WORKDIR /home/$USERNAME/app

# shiny app configuration
ENV LISTENING_ADDRESS "0.0.0.0"
ENV LISTENING_PORT "3838"

CMD ["R", "-e", "shiny::runApp('./')"]
