# Maintainance

To run any sort of database maintainance through this app, follow these steps:

1. Create the maintainance file in Maintainance folder. See template.dart file in the folder for more details.
2. Run ```bash ./scripts/run_maintainance.sh {filename}``` in this folder
3. Log the appropriate changes and errors in the app
4. To update changes from main.dart back to the maintainance file, run ``` bash ./scripts/update_maintainance.dart ```
5. After maintainance has been completed, run ``` bash ./scripts/exit_maintainance.sh {filename} ```

**Do not delete main_maintainance.dart whilst doing maintainance**