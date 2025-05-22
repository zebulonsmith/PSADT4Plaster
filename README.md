# PSADT4Plaster
This repo contains a Plaster template for PSADT 4 as well as some "helper" scripts that can be used for building ADT packages. 

The goal is to make it easy to standardize app packaging processes and reduce development time. 

Before using this module, ensure that you're familiar both with the [Powershell App Deploy Toolkit](https://psappdeploytoolkit.com/) and [Plaster module](https://github.com/PowerShellOrg/Plaster). 

# How it Works
The included Plaster template will copy the contents of the PSADT (Currently version 4.0.3) and make edits to config.psd1 and Invoke-AppDeployToolkit.ps1 as defined in the Plaster invocation. 
