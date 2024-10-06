# Optimus2024Shakti
This is the repository of the Wind Turbine development project from the 3. semester students  of the wind energy engineering master from the university of applied science Flensburg, Germany.

### Never worked with Git and repositorys before or not sure what to do? - See the small guide to git below.

# File Structure
```md
Optimus2024
 ┣ .git
 ┣ IEA-3.4-130-RWT
 ┣ PresentationTemplate
 ┣ .gitignore
 ┗ README.md
```

# Git Guide
Git is powerful and commonly used software tool for managing version history of files, espically ASCII based files e.g. the files of OpenFAST or MATLAB. 

### What do you need to know first?
1. If you read these instructions before starting you work in this repository (this how an folder is called that is managed by git) you should have an basic understanding of what you can do, what you can't and what you shouldn't do. 
2. If you want to just read files and browse through everything you can stop reading here. This is possible without any login or such thing. You can even download files if you want to. If this is not the case go to the next point.
3. First you need to create a GitHub Account. Go to the [GitHub](https://github.com/) website and create yourself an Account. Please add your full name to the profile in your account for the duration you are participating in the Optimus project. A little manual on how to that you can find [here](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/personalizing-your-profile). You can change this back after the project is done. This is just so we can easier identify the people. 
4. After you GitHub Account is ready to use you can send your account name to Julius, Felix or Soni. We than grand you writing permissions to the project.
5. Before you now start working on the Optimus GitHub Project files you need do these two tutorials.
    * First do the [general tutorial for git](https://docs.github.com/en/get-started/start-your-journey/hello-world) and play a little bit around with the stuff you learned there.
    * Second do the tutorial for the [GitHub desktop app](https://docs.github.com/en/desktop/overview/getting-started-with-github-desktop).

### How do we want to work?
Now that you know about branches, commits and pull request you would be able to start working on the Optimus Project GitHub repo (short for repositiory). Not so FAST we need to discuss some rules first. 

The projects repo consists of two branches _main_ and _develop_. 

* _main_: This branch is the main branch. Here is everytime a working version of the projects model, CAD models and other files available. This branch will be updated from time to time if we reach a point where the changes become permanent. You could say we are than upgrading to the next "version".
* _develop_: This branch is a work in progress. If you have made changes to the model e.g. the rotor blade group has new NACA profiles created. Than these changes will be applied to the _develop_ branch and can be tested by all other groups. After sufficient testing these changes will be applied to the _main_ branch and we have a new version of our turbine.

Both of these branches are protected. Meaning that changes to these branches can be made only via a **pull request**. The current settings are also that another person has to review the changes that are made. After that the changes combined in the pull request can be applied to the _develop_ branch. 

In order to submit a pull request you have to create a new branch, a so called _feature-branch_. Give this branch a good and understandable name. For example: _new-rated-power_.

#### Summary of the working process
1. Create a new branch (feature branch)
    
    * either from the _main_ branch,
    * from the _develop_ branch 
    * or from any other existing branch
2. Make the changes you wanted to do, add new files, whatever needs to be done.
3. Submit a pull request where you want to merge your created branch into the _develop_ branch.
4. Assign someone to review you changes.
5. Wait for the review.
6. After the review was positive you can merge.
7. The new feature or the changes are now applied to the _develop_ branch and will be tested and than maybe merged into the _main_ branch with the release of the next version of our turbine.


