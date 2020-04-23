FROM alpine:latest

# Install OpenSSH server with PAM support, and google-authenticator
RUN apk add openssh-server openssh-server-pam google-authenticator

# sshd server config and host keys
COPY sshd_config /etc/ssh/sshd_config
COPY keys/host/* /etc/ssh
COPY keys/signing/id_ed25519.pub /etc/ssh/trusted_CAs

COPY pam_sshd /etc/pam.d/sshd

# Create some users and give them default passwords
RUN printf "pepboys\npepboys\n" | adduser manny ; \
    printf "pepboys\npepboys\n" | adduser moe ; \
    printf "pepboys\npepboys\n" | adduser jack;

# Setup user manny with GoogleAuthenticator configuration in place
COPY google_auth /home/manny/.google_authenticator
RUN chown manny. /home/manny/.google_authenticator && chmod 400 /home/manny/.google_authenticator
COPY manny_qrcode /etc/ssh/manny_qrcode

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd"]
# Send logs (debug) to stderr, so docker logs can fetch them
CMD ["-D", "-d", "-e"]
