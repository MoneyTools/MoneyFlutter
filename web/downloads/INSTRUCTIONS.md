# Desktop Files

## Steps

1. Navigate to the **Actions** tab on GitHub under the `main` branch.
2. Select the most recent successful workflow run.
3. Open the selected workflow.
4. Locate the four artifacts at the bottom of the workflow page (note: there are now two for macOS):
    - `mymoney-app-linux.zip`
    - `mymoney-app-macos-intel.zip`
    - `mymoney-app-macos-silicon.zip`
    - `mymoney-app-windows.zip`
5. Download these files and move them to the `web/downloads` folder.
6. Execute `firebase deploy` to deploy the application.
7. After deployment, you can delete the four downloaded files as they are excluded by `.gitignore`:
    - `mymoney-app-linux.zip`
    - `mymoney-app-macos-intel.zip`
    - `mymoney-app-macos-silicon.zip`
    - `mymoney-app-windows.zip`
