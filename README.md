# chef-dokku-simple cookbook

I am a simple man. Dokku is simple software. It should have a simple
cookbook.

This cookbook just runs dokku's default bootstrap script, and installs
your ssh keys for access to dokku. If you need more power, you should
check out [chef-dokku](https://github.com/fgrehm/chef-dokku).

## Attributes

- `[:dokku][:tag]`: git tag to install
- `[:dokku][:root]`: home dir for dokku (default: `/home/dokku`)
- `['dokku'][:ssh_users]`: array of usernames to lookup ssh keys in
  data bag `users` (see below)
- `[:dokku][:vhost]`: domain for virtual hosting

## SSH keys

You need to add ssh keys that may `git push` apps to your dokku
instance. This cookbook looks up `ssh_keys` as a string or array (of
multiple keys) for each configured user in the data bag `users`. This
is for compatibility with the
[ssh-keys cookbook](https://github.com/nickola/chef-ssh-keys).

## Domain

You will need to setup a wildcard domain pointing to your host (unless
you want each app on a different port). Unless `dig +short $(hostname -f)`
gives the correct answer, you need to configure with `[:dokku][:vhost]`.

## Usage

Just include `dokku-simple` in your node's `run_list`:

```json
{
  "dokku": {
    "tag": "v0.2.2",
    "root": "/home/dokku",
    "ssh_users": [ "lindsey", "jeff" ],
    "vhost": "dokku.me"
  },

  "run_list": [
    "recipe[dokku-simple]"
  ]
}
```
