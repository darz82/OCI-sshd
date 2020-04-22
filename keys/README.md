# Keys

All keys here should only be used within the container - for any real purpose, generate new, secured keys.

None of the private keys are passphrase protected, and are only for basic demonstration purposes. 

- `signing/` - One ed25519 key that is used for signing both host keys and user keys. The server config is set with the directive `TrustedUserCAKeys`, so that any certificate signed by this key is trusted for user authenitcation (provided that there is a valid principal name in the certificate, and that the client has the original **private** key for the user (not CA).  Clients can be conficured to trust Host keys signed by this CA, by prefixing a `known_hosts` entry with **@cert-authority**.

- `host/` - Three keys that are copied into the container as SSH host keys, rather than allowing the container to generate on first use. RSA, ECDSA(384-bit), and ed25519 keys are included, but only the ed25519 key has a corresponding certificate. In addition, the `sshd_config` specifically enables only 521-bit ECDSA keys, making the 384-bit key on the host effectively disabled.

- `users/` - Four keys, one for each defined user (root, manny, moe, jack), plus a signed certificate for each. Non-root users only list their own name as the certificate principal. root's certificate includes all four names listed as principals, allowing direct authenticated logins for any user.

Note: none of the user home directories contain a `.ssh/authorized_keys` file. With the `TrustedUserCAKeys` setup in place, explicit entries are not needed, although if testing plain public key authentication, the .ssh directory and authorized_keys file can be added later.
