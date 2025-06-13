# ssh-hydruh
A bash script that tries a set of SSH key files against a list of users and hosts. 

> *SSH key-based credential spraying*

---

## Usage

```bash
Usage: ./hydruh.sh <key_directory> <hosts_file> <users_file>
  key_directory: Path to the directory containing SSH key files.
  hosts_file: Path to the file containing the list of hosts.
  users_file: Path to the file containing the list of users.
Options:
  -h: Display this help message.
```

:point_right: The `hosts_file` and `users_file` will ignore lines that start with a `#` comment character

:point_right: Forks a separate process for each host, while looping through users iteratively. This means that even modest sshd won't be overwhelmed.

:point_right: Connectivity to each host will be tested with a simple `ping`, but this doesn't exclude the host from the SSH attempts - it's just for your information.

## To-Do

- [ ] Improve output to show when a connection times-out
- [x] Add a check that pings the host to see if there is any connection at all

## Disclaimer

> #### :warning: Please only use this tool as lawfully applicable. :warning:
> You may only use this tool against hosts for which you have written explicit permission to attempt authentication.

**Please :star: this repo if you found it useful!**

---

Enjoy,

:handshake::handshake::handshake::handshake:
@4wayhandshake
