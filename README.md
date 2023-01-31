# `isaac-steam-workshop-upload`

<!-- markdownlint-disable MD001 MD033 -->

This GitHub action allows you to upload your _[Binding of Isaac: Repentance](https://store.steampowered.com/app/1426300/The_Binding_of_Isaac_Repentance/)_ mod to [the Steam Workshop](https://steamcommunity.com/app/250900/workshop/).

Under the hood, it uses [`steamcmd`](https://developer.valvesoftware.com/wiki/SteamCMD) to do this.

Using this action to perform uploads in CI is useful because it allows for multiple people on a team to be able to trigger releases, and it allows for automated releases without having to use a GUI.

<br />

## First Publish

This action can not be used to perform the first upload for your mod publish, since it needs to use an existing mod ID. Instead, use the bundled mod uploader that comes with the game for this purpose. By default, it is located at:

```text
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\tools\ModUploader\ModUploader.exe
```

After publishing your mod for the first time, the `id` field will appear inside of your "metadata.xml" file. (This ID corresponds to the URL for your mod on the Steam Workshop.)

<br />

## `mod` Subdirectory

This action assumes that your repository has a "mod" subdirectory that contains the files that will be published to the Steam Workshop:

```text
project/
└── mod/
    ├── main.lua
    └── metadata.xml
```

The action will look in the "metadata.xml" file to find your mod's ID.

<br />

## Repository Secrets

For this action to work, it needs three repository secrets to be in place:

- `STEAM_USERNAME`
- `STEAM_PASSWORD`
- `STEAM_GUARD_CODE`

Add secrets to your repository by following these steps:

- Go to the main page for your repository.
- Click on the "Settings" tab near the top.
- Click on the "Secrets and variables" selection on the left menu.
- Click on the "Actions" page.
- Click on the "New repository secret" button in the top right.
- For the "Name" box, use: `STEAM_USERNAME`
- For the "Secret" box, enter your username.
- Repeat this process for: `STEAM_PASSWORD`
- Attempt to trigger the GitHub action. (See the below "Example Usage" section for more information.)
- The action will fail due to Steam Guard being triggered. You should now get an email containing your Steam Guard token, which should be a 5 digit string something like "A1B2C".
- Add this string as a repository secret for `STEAM_GUARD_CODE` (in the same way that you did for `STEAM_USERNAME` and `STEAM_PASSWORD` earlier on).
- Attempt to trigger the GitHub action again, and it should work.

<br />

## Example Usage

The following example workflow file showcases how you can use this GitHub action to automatically publish your mod whenever a commit is pushed to the repository main branch with a message containing "chore: release".

#### `.github/workflows/ci.yml`

```yml
on:
  push:
    branches:
      - main

jobs:
  publish_to_steam_workshop:
    needs: [build_and_lint]
    if: "contains(github.event.head_commit.message, 'chore: release') && github.event_name != 'pull_request'"
    runs-on: ubuntu-latest
    steps:
      - uses: IsaacScript/isaac-steam-workshop-upload@v1
        env:
          STEAM_USERNAME: ${{ secrets.STEAM_USERNAME }}
          STEAM_PASSWORD: ${{ secrets.STEAM_PASSWORD }}
          STEAM_GUARD_CODE: ${{ secrets.STEAM_GUARD_CODE }}
```

<br />
