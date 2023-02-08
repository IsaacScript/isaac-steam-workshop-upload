# `isaac-steam-workshop-upload`

<!-- markdownlint-disable MD001 MD033 -->

This GitHub action allows you to upload your _[Binding of Isaac: Repentance](https://store.steampowered.com/app/1426300/The_Binding_of_Isaac_Repentance/)_ mod to [the Steam Workshop](https://steamcommunity.com/app/250900/workshop/).

Using this action to perform uploads in CI is useful because it allows for multiple people on a team to be able to trigger releases, and it allows for automated releases without having to manually use the GUI.

<br>

## Example Usage

The following file showcases how you can use this GitHub action to automatically publish your mod whenever a commit is pushed to the repository main branch with a message containing the "chore: release" prefix. (This syntax is part of the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard, which we recommend that you use for your repository.)

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
        with:
          mod_path: .
        env:
          CONFIG_VDF_CONTENTS: ${{ secrets.CONFIG_VDF_CONTENTS }}
```

Note that:

- `mod_path` refers to the directory to upload. See the [variables section](#list-of-variables) below.
- `CONFIG_VDF_CONTENTS` refers to a GitHub repository secret that contains the "config.vdf" file with your Steam credentials. See the [authentication section](#authentication--steam-guard) below.

<br>

## List of Variables

- `mod_path` - Required. Represents the subdirectory of the repository that will be uploaded to the Steam Workshop. IsaacScript mods should use a value of `mod`. If you want the base of your repository to be uploaded, use a value of: `.`
- `ignore_files` - Optional. See the [section on ignored files](#ignored-files) below.
- `change_note` - Optional. The message to write to the "Change Notes" tab on the Steam Workshop. See the [section on change notes](#change-notes) below.

For environment variables / GitHub repository secrets, see the [authentication section](#authentication--steam-guard) below.

<br>

## First Upload

This action can not be used to perform the first upload for your mod, since it needs to use an existing mod ID. Instead, use the bundled mod uploader GUI that comes with the game to first upload the mod. By default, it is located at:

```text
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\tools\ModUploader\ModUploader.exe
```

After uploading a mod for the first time, the `id` field will appear inside of the "metadata.xml" file. (This ID corresponds to the URL for the mod on the Steam Workshop.)

<br>

## Ignored Files

By default, this action will not upload:

- any files or directories that begin with a period (e.g. `.git` or `.eslintrc.cjs`)
- the "disable.it" file, if it exists

If you want to ignore additional files beyond that, you can use the `ignore_files` variable. This takes a comma separated list of files to ignore.

For example:

```yml
with:
  mod_path: .
  ignore_files: cspell.json,release.py
```

<br>

## Change Notes

On the main page of the Steam Workshop for your mod, you will see a "Change Notes" tab that lists every version of the mod that has been uploaded. This is a place where people conventionally write messages about what they have changed.

It is recommended that you do NOT use this feature of the Steam Workshop, because change logs should be tracked in version control alongside all of your other code.

By default, this action will create a change note of:

```text
Version: {VERSION}
```

Where `{VERSION}` is equal to the version of your mod reported in the commit message. For example, if you trigger the CI action with a commit message of: `chore: release 1.2.3`, then `1.2.3` would be written. (We assume that you are using [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/).)

If you want to customize this behavior, then you can use the `change_note` variable. For example:

```yml
with:
  mod_path: .
  change_note: "Changes for this mod are [url=https://github.com/wofsauge/External-Item-Descriptions/releases]tracked on GitHub[/url]."
```

Additionally, you can use the special string of `{VERSION}` in your message, which will get automatically filled with the version from the release commit. (Again, the parser assumes that you are using conventional commits.) For example:

```yml
with:
  mod_path: .
  change_note: "Version: {VERSION}\n\nChanges for this mod are [url=https://github.com/wofsauge/External-Item-Descriptions/releases]tracked on GitHub[/url]."
```

<br>

## Authentication & Steam Guard

### Introduction

"Steam Guard" is a feature that provides [two-factor authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication) for Steam accounts. It makes it so that in order to log in, you must additionally provide a five digit code that is sent to your email address.

Steam Guard applies by default to all Steam accounts. This means that simply providing this GitHub action with your Steam username and password is not sufficient for it to actually be able to upload your mod, so a more complicated approach is necessary.

Under the hood, this GitHub action uses [`steamcmd`](https://developer.valvesoftware.com/wiki/SteamCMD) to communicate with Steam. `steamcmd` handily caches the credentials that it uses, such that you only need to provide it with your password one time, and you only need to paste the five digit code from your email one time. It does this by putting encrypted data in the `~/Steam/config/config.vdf` file. (The `~` character is short for the home directory on Linux.)

This GitHub action requires that you first run `steamcmd` on your own, authenticate with it, and then copy paste the resulting `config.vdf` file as a GitHub secret under the name of `CONFIG_VDF_CONTENTS`.

### Detailed How-To

`steamcmd` can be run on either Windows or Linux, but we recommend that you use Linux. From a fresh Ubuntu Server, you can install it like this:

```bash
sudo apt install software-properties-common -y
sudo add-apt-repository multiverse -y
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install steamcmd -y
```

Next, run `steamcmd` and login:

```bash
steamcmd +login foo +quit # Replace "foo" with your Steam username.
```

You will be prompted for your password and the five digit Steam Guard code. If successful, the program will then exit.

Next, print out the contents of the `~/Steam/config/config.vdf` file and put it in your clipboard:

```bash
cat ~/Steam/config/config.vdf
```

Next, add it as a repository secret by following these steps:

- Go to the main page for your GitHub repository.
- Click on the "Settings" tab near the top.
- Click on the "Secrets and variables" selection on the left menu.
- Click on the "Actions" page.
- Click on the "New repository secret" button in the top right.
- For the "Name" box, use: `CONFIG_VDF_CONTENTS`
- For the "Secret" box, paste in the contents of the file.

Now, you can attempt to trigger the GitHub action to see if it works.

<br>

## IsaacScript

If you find this GitHub action useful, you should consider using it in a TypeScript mod. TypeScript has the advantage of auto-complete, auto-importing, and the compiler preventing you from ever making a typo. Taken together, it makes for a dream-like Isaac development experience.

For more information, see the [list of features](https://isaacscript.github.io/main/features). (If you don't know how to program in TypeScript, then you can learn in around [30 minutes](https://isaacscript.github.io/main/javascript-tutorial).)

<br>

## Prior Art

You might also be interested in the following GitHub actions:

- [Steam Deploy](https://github.com/game-ci/steam-deploy)
- [Steam Workshop Upload](https://github.com/Weilbyte/steam-workshop-upload)
- [Steam Workshop Upload Action](https://github.com/arma-actions/workshop-upload)

<br>
