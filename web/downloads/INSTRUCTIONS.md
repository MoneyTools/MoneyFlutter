# Desktop Files

## Steps

1. Navigate to the **Actions** tab on GitHub under the `main` branch.
2. Select the most recent successful workflow run.
3. Open the selected workflow.
4. Locate the three artifacts at the bottom of the workflow page:
    - `flutter-linux-app.zip`
    - `flutter-macos-app.zip`
    - `flutter-windows-app.zip`
5. Download these files and move them to the `web/downloads` folder.
6. Execute `firebase deploy` to deploy the application.
7. After deployment, you can delete the three downloaded files as they are excluded by `.gitignore`.
