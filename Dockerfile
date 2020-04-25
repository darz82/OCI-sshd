FROM alpine:latest

# Install OpenSSH server with PAM support, and google-authenticator
RUN apk add openssh-server openssh-server-pam google-authenticator

# sshd server config and host keys
COPY sshd_config /etc/ssh/sshd_config
COPY keys/host/* /etc/ssh/
# sshd_config refers to this file of trusted CA public keys
COPY keys/signing/id_ed25519.pub /etc/ssh/trusted_CAs

# Necessary PAM config for ChallengeResponse w/TOTP
COPY pam_sshd /etc/pam.d/sshd

# Copy trusted_hosts file into /etc/ssh/known_hosts for
# HostBasedAuthentication and setup shosts.equiv file to allow
# from localhost - other hosts can be added, one per line.
COPY trusted_hosts /etc/ssh/ssh_known_hosts
RUN echo "127.0.0.1" > /etc/ssh/shosts.equiv


# Create some users and give them default passwords
# Note: to use HostbasedAuthentication, the local user MUST match between
# client and server side. "user@host" or "-l user" is not applicable when
# using HostbasedAuthentication without additional configuration of
# ~/.shosts file for each destination user..
RUN printf "pepboy1\npepboy1\n" | adduser manny ; \
    printf "pepboy2\npepboy2\n" | adduser moe ; \
    printf "pepboy3\npepboy3\n" | adduser jack; \
    printf "notapepboy\nnotapepboy\n" | adduser paul

# Configure user paul to trust an additional CA
RUN mkdir /home/paul/.ssh && echo 'cert-authority,principals="paul" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqQyVtIit8/cEgcQBjw6PLbN+8XpBwSG4ulb4drO14f' > /home/paul/.ssh/authorized_keys && chown -R paul. /home/paul/.ssh

# Setup user manny with GoogleAuthenticator configuration in place
COPY google_auth /home/manny/.google_authenticator
RUN chown manny. /home/manny/.google_authenticator && chmod 400 /home/manny/.google_authenticator
COPY manny_qrcode /etc/ssh/manny_qrcode

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd"]
# Use -D option to not daemonize, stay in foreground so the container
# doesn't exit when sshd forks, then terminates.
# Use -e option to send logs (debug) to stderr, so docker logs can fetch them
# Alternatively, running explicitly with "-D -d" will run with debug logging
# and terminate the container after a single connection completes.
CMD ["-D", "-e"]
