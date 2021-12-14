# Network Location Awareness tweaks

I've had problems with NLA on some systems deciding that it has no internet connection.  Since the MS Store and (most? all?) of its apps depend on NLA to tell them if a usable network connection exists, this creates problems.

[NLA-workaround.reg](NLA-workaround.reg) contains some registry changes to enable custom targets for NLA to work with.

[forcibly-restart-nlasvc.ps1](forcibly-restart-nlasvc.ps1) contains a PowerShell script to forcibly restart NLA -- killing its process, if necessary.
