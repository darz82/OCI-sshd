# OCI-sshd
sshd server in an OCI container for testing with Podman/Docker

Allows setup and configuration without the need for a designated server
or VM environment.

Current configuration based on Alpine (latest, uses OpenSSH 8.1), and sets up root and 3 additional users (1 with support for TOTP/GoogleAuthenitcator). Users (plus root) and Host keys are generated under `keys/`, and a CA signing key is included as well. The CA key has signed for basic certificates for each user and host key.
