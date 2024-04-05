FROM adoptopenjdk/openjdk13:debianslim

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc && rm -rf /usr/share/man \
    && apt-get clean

WORKDIR /usr/tsunami/repos

# Clone the plugins repo
RUN git clone --depth 1 "https://github.com/google/tsunami-security-scanner-plugins"

# Build plugins
WORKDIR /usr/tsunami/repos/tsunami-security-scanner-plugins/google
RUN chmod +x build_all.sh \
    && ./build_all.sh

RUN mkdir /usr/tsunami/plugins \
    && cp build/plugins/*.jar /usr/tsunami/plugins

# Compile the Tsunami scanner
WORKDIR /usr/repos/tsunami-security-scanner
COPY . .
RUN ./gradlew shadowJar \
    && cp "$(find "./" -name "tsunami-main-*-cli.jar")" /usr/tsunami/tsunami.jar \
    && cp ./tsunami.yaml /usr/tsunami

# Copy the script
COPY run_scan_and_parse.sh /usr/tsunami/run_scan_and_parse.sh
COPY tsunami_output_parser.py /usr/tsunami/tsunami_output_parser.py

# Set execute permissions
RUN chmod +x /usr/tsunami/run_scan_and_parse.sh
RUN chmod +x /usr/tsunami/tsunami_output_parser.py

# Stage 2: Release
FROM adoptopenjdk/openjdk13:debianslim-jre

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends nmap ncrack ca-certificates python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc && rm -rf /usr/share/man \
    && apt-get clean

WORKDIR /usr/tsunami
RUN mkdir /usr/tsunami/logs

COPY --from=0 /usr/tsunami /usr/tsunami

# Set entry point
ENTRYPOINT ["/bin/bash", "/usr/tsunami/run_scan_and_parse.sh"]
