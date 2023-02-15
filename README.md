# ARCHIVED
This project is no longer being maintained, check out [asdf](https://asdf-vm.com/) as an alternative.

# Belt
A single version manager for all your tools with one simple interface

### Instalation

1. Clone the repo somewhere (e.g. ~/belt)
```
git clone https://github.com/jescholl/belt.git ~/belt
```
2. Initialize belt in your .bashrc or .zshrc
```
source <(~/belt/belt.sh init)
```

### Usage

Simply use your favorite tools the way you normally would, they will be downloaded if necessary before use

#### Managing versions

There are multiple different ways to manage versions, and if no version is set it will simply use the latest version found locally, and download the latest remote version if none exists locally

* Environment variables
```
› export BELT_TERRAFORM_VERSION=1.0.10
› terraform version
Terraform v1.0.10
on darwin_amd64
```

* Version files
```
› cat .consul-version
1.10.3

› consul version
Consul v1.10.3
Revision c976ffd2d
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)
```

* Default versions
```
› belt use kubectl 1.22.2
› kubectl version
Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.2", GitCommit:"8b5a19147530eaac9476b0ab82980b4088bbc1b2", GitTreeState:"clean", BuildDate:"2021-09-15T21:38:50Z", GoVersion:"go1.16.8", Compiler:"gc", Platform:"darwin/amd64"}
```

#### List installed tools and versions

```
› belt versions
consul:
  * 1.10.3 (Set in /Users/jscholl/.consul-version)
kubectl:
  * 1.22.2 (Set in /Users/jscholl/.belt/.kubectl-version)
    1.10.3
    1.10.2
    1.10.1
    1.10.0
nomad:
  * 1.1.6 (No version set, using latest installed)
packer:
  * 1.7.7 (No version set, using latest installed)
terraform:
  * 1.0.10 (Set with $BELT_TERRAFORM_VERSION)
    1.0.9
vault:
  * 1.8.4 (No version set, using latest installed)
```


### Coming soon

* Autocomplete
* Better error messages
