# Use the latest official Microsoft SQL Server image on Linux
FROM mcr.microsoft.com/mssql/server:2022-latest

# Set the working directory inside the container
WORKDIR /app

# Set environment variables
# IMPORTANT: Accept the End-User Licensing Agreement
ENV ACCEPT_EULA=Y
# Set a strong password for the SA user. Change this for production!
ENV SA_PASSWORD="YourStrongP@ssw0rd!"

# Install curl to download the script and dos2unix to fix potential line ending issues
# The -y flag automatically answers "yes" to any prompts
RUN apt-get update && apt-get install -y curl dos2unix

# Download your SQL script from the GitHub repository and run dos2unix on it
RUN curl -o Full_Database.sql https://raw.githubusercontent.com/maher-dataconsult/g1_examination_system/main/Full_Database.sql && \
    dos2unix Full_Database.sql

# Copy the custom entrypoint and initialization scripts into the container
COPY ./entrypoint.sh .
COPY ./run-initialization.sh .

# Make the scripts executable
RUN chmod +x ./entrypoint.sh
RUN chmod +x ./run-initialization.sh

# Set the entrypoint to our custom script
CMD ["/bin/bash", "./entrypoint.sh"]