# `isaac-steam-workshop-upload`

<!-- markdownlint-disable MD001 MD033 -->

This GitHub action allows you to upload your _[Binding of Isaac: Repentance](https://store.steampowered.com/app/1426300/The_Binding_of_Isaac_Repentance/)_ mod to [the Steam Workshop](https://steamcommunity.com/app/250900/workshop/).

Using this action to perform uploads in CI is useful because it allows for multiple people on a team to be able to trigger releases, and it allows for automated releases without having to manually use the GUI.

<br />

## Example Usage

The following file showcases how you can use this GitHub action to automatically publish your mod whenever a commit is pushed to the repository main branch with a message containing "chore: release".

#### `.github/workflows/ci.yml`

```yml
on:
  push:
    branches:
      - main

jobs:
  build_and_lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the repository
        uses: actions/checkout@v3

      # Your other CI tasks would go here, if you have any. (e.g. building artifacts, linting)

      - name: Upload the mod to Steam Workshop (if this is a release commit)
        uses: IsaacScript/isaac-steam-workshop-upload@v1
        if: "contains(github.event.head_commit.message, 'chore: release') && github.event_name != 'pull_request'"
        env:
          CONFIG_VDF_CONTENTS: ${{ secrets.CONFIG_VDF_CONTENTS }}
```

Note that the action will only work if you have added the ["config.vdf" file as a repository secret](#authentication--steam-guard); see below.

<br />

## First Upload

This action can not be used to perform the first upload for your mod, since it needs to use an existing mod ID. Instead, use the bundled mod uploader GUI that comes with the game to first upload the mod. By default, it is located at:

```text
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\tools\ModUploader\ModUploader.exe
```

After uploading a mod for the first time, the `id` field will appear inside of the "metadata.xml" file. (This ID corresponds to the URL for the mod on the Steam Workshop.)

<br />

## `mod` Subdirectory

This action assumes that your repository has a "mod" subdirectory that contains the files that will be published to the Steam Workshop. Thus, your repository should look something like this:

```text
project/
├── .git/
└── mod/
    ├── main.lua
    └── metadata.xml
```

The action will look in the "metadata.xml" file to find your mod's ID.

<br />

## Authentication & Steam Guard

### Introduction

"Steam Guard" is a feature that provides [two-factor authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication) for Steam accounts. It makes it so that in order to log in, you must additionally provide a five digit code that is sent to your email address.

Steam Guard applies by default to all Steam accounts. This means that simply providing this GitHub action with your Steam username and password is not sufficient for it to actually be able to upload your mod, so a more complicated approach is necessary.

Under the hood, this GitHub action uses [`steamcmd`](https://developer.valvesoftware.com/wiki/SteamCMD) to communicate with Steam. `steamcmd` handily caches the credentials that it uses, such that you only need to provide it with your password one time, and you only need to paste the five digit code from your email one time. It does this by putting encrypted data in the `~/Steam/config/config.vdf` file. (The `~` character is short for the home directory on Linux.)

This GitHub action requires that you first run `steamcmd` on your own, authenticate with it, and then copy paste the resulting `config.vdf` file as a GitHub secret under the name of `CONFIG_VDF_CONTENTS`.

### How-To

`steamcmd` can be run on either Windows or Linux, but we recommend that you use Linux. From a fresh Ubuntu Server, you can install it like this:

```bash
sudo apt install software-properties-common -y
sudo add-apt-repository multiverse -y
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steamcmd -y
```

Next, run the following script:

```bash
curl -o- https://raw.githubusercontent.com/IsaacScript/isaac-steam-workshop-upload/main/get_steamcmd_credentials.sh | bash
```

The script will:

- run `steamcmd`, which will prompt you for your username + password + Steam Guard code
- print out the contents of the `~/Steam/config/config.vdf` file

Once you have the contents of the `config.vdf` file in your clipboard, add it as a repository secret by following these steps:

- Go to the main page for your GitHub repository.
- Click on the "Settings" tab near the top.
- Click on the "Secrets and variables" selection on the left menu.
- Click on the "Actions" page.
- Click on the "New repository secret" button in the top right.
- For the "Name" box, use: `CONFIG_VDF_CONTENTS`
- For the "Secret" box, paste in the contents of the file.

Now, you can attempt to trigger the GitHub action to see if it works.

<br />
