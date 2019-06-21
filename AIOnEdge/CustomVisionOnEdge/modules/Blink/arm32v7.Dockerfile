FROM balenalib/raspberrypi3

# Update package index and install dependencies
RUN install_packages \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    libopenjp2-7-dev \
    zlib1g-dev \
    libatlas-base-dev \
    wget \
    libboost-python1.62.0 \
    curl \
    libcurl4-openssl-dev

# Required for sound
RUN install_packages \
    # audio speaker 
    espeak \
    # sound player
    mpg321 \
    # Pico (Google Android TTS)
    libttspico-utils -y --allow-unauthenticated

RUN usermod -a -G video root

FROM microsoft/dotnet:2.1-sdk AS build-env
WORKDIR /app
 
COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out

FROM microsoft/dotnet:2.1-runtime-stretch-slim-arm32v7
WORKDIR /app
COPY --from=build-env /app/out ./
COPY /assets/* ./
RUN chmod +777 /app/*.2.*

RUN useradd -ms /bin/bash moduleuser
#RUN chown moduleuser /dev/gpiomem
#RUN chmod g+rw /dev/gpiomem
#USER moduleuser


ENTRYPOINT ["dotnet", "Blink.dll"]