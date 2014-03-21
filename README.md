# chef-dokku-simple cookbook

[Dokku](https://github.com/progrium/dokku) is simple software. It
should have a simple cookbook.

This cookbook just runs dokku's default
[bootstrap script](https://github.com/progrium/dokku/blob/master/bootstrap.sh),
and installs your ssh keys for access to dokku. If you need more
power, you should check out
[chef-dokku](https://github.com/fgrehm/chef-dokku).

## Attributes

Attribute | Description | Type | Default
----------|-------------|------|--------
`[:dokku][:tag]` | git tag to install | String | `v0.2.2`
`[:dokku][:root]` | home dir for dokku | String | `/home/dokku`
`[:dokku][:ssh_users]` | array of usernames to lookup ssh keys in data bag `users` (see below) | Array | []
`[:dokku][:vhost]` | domain for virtual hosting | String | nil
`[:dokku][:apps]` | hash of apps to configure with env vars | Hash | {}

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

## Environment variables

To pre-configure environment for an application, add to the `apps`
attribute as shown below in Usage.

## Usage

Just include `dokku-simple` in your node's `run_list`:

```json
{
  "dokku": {
    "tag": "v0.2.2",
    "root": "/home/dokku",
    "ssh_users": [ "lindsey", "jeff" ],
    "vhost": "dokku.me",
    "apps": {
      "my_app": {
        "env": { "TOKEN": "123" }
      }
    }
  },

  "run_list": [
    "recipe[dokku-simple]"
  ]
}
```
