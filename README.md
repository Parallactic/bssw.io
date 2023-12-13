# BSSw.io 

## ﻿Intro
The bssw.io site software (available at https://github.com/Parallactic/bssw.io) has two main functions: it runs a Ruby on Rails site with typical model/view/controller architecture that displays content (as visible at https://bssw.io), and it runs a rebuild process that visits a GitHub repository (https://github.com/betterscientificsoftware/bssw.io/) and imports content from the Markdown files there into its database. This enables the BSSw team to use a GitHub/Markdown workflow to manage the content via the familiar GitHub interface (or via the Git client of their  choice).


## Structure
* Basic Ruby on Rails structure:
  * Some introductions to the Rails framework: https://www.tutorialspoint.com/ruby-on-rails/rails-framework.htm, https://guides.rubyonrails.org/getting_started.html, https://www.startuprocket.com/articles/a-quick-introduction-to-ruby-on-rails    * Code is contained in the app/ folder; app/assets contains images stylesheets, and javascript; app/controllers contains Rails controllers which populate needed variables for the views; app/views contains erb files, which are a mix of Ruby code and HTML that ends up generating the HTML for the webpages 
  * Tests are contained in the spec/ folder; the tests use the Rspec framework (more info on Rspec: https://longliveruby.com/articles/introduction-to-rspec, https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-programming/lessons/introduction-to-rspec)        
  * Gemfile (in the root directory) contains references to the external libraries used for the project. (https://bundler.io/gemfile.html has more on the use of gems and the Gemfile)
* BSSw-specific structure:
  * In a typical Rails app, the app/models folder contains the meatiest part of the code - models, which usually map to database tables, and which contain the majority of code behavior. However, in our case we’ve broken these out into a few folders for organization, because of the large number of models we use:
    * app/site/ contains models for first-order objects that are displayed on the site (Page, Event, BlogPost, Resource, Author, etc)
    * app/parent_classes/ contains models with shared functionality, that models in app/site/ inherit from
    * app/utilities/ contains classes that do processing work during the rebuild process

## The Rebuild Process - Intro
* Each of the models used on the site stores a “rebuild_id”. 5 copies of each item from old rebuilds are kept. The site displays items whose “rebuild_id” matches the stored “display_rebuild_id” - after a rebuild is completed successfully, it is set as the displayed rebuild. If for any reason the rebuild does not complete successfully, the displayed rebuild is not updated and the content does not change. There is also an option to set the displayed rebuild to an older rebuild (from the 5 most recent), to revert content changes.
* The rebuild process is kicked off manually by visiting the password-protected page https://bssw.io/rebuilds (which also contains information about the most recent rebuilds) and clicking “rebuild now”


## The Rebuild Process - Details
* The RebuildsController import method begins by creating a Rebuild object, then calls RebuildStatus.start and GithubImporter.populate
* RebuildStatus.start marks this rebuild as in progress, and records meta information about the rebuild
* GithubImporter.populate begins by downloading a copy of the entire content repository as a zipped file
* It then unzips the content, and sends each markdown file (except those in the hard-coded “excluded_filenames” list) to the in-progress Rebuild object’s “process_file” method
* “Process_file” attempts to run “process_path” on the file. If this is successful, the filename is added to the rebuild’s list of processed files. If any errors occur, the errors are stored in the rebuild’s error log.
* If the file is “Quotes.md” or “Announcements.md”, it is sent to those classes for special processing
* Otherwise, a site object (WhatIs, HowTo, Category, Fellow, Community, Page, Event, BlogPost, or Resource) is created from the file; the class for the site object is chosen based on the file path, via a hard-coded mapping of file path patterns to classes
* All site objects inherit from the GithubImport parent class, which defines the base form of the update_from_content method that parses the HTML generated from the Markdown to fill the site object with content
* How the content is processed, generally:
  * The title is selected from the highest-ranking heading (e.g. h1, h2) in the HTML
  * If there is an h4 containing the words “Publication date”, the publication date is set based on that; if there is not, GitHub is revisited to track down the date of the first commit containing this file
  * The item’s authors are set based on an h4 containing the text “Contributed”
    * Each comma-separated author name is then parsed. If the name is a link, the website in the href is used as the unique marker for this author; otherwise, the name is used. By default, the author’s last name is the last space-separated word of the name, and the author will be listed alphabetically by that name.
  * The metadata from comments is parsed, which may include:
    * Topics
    * Tracks
    * OpenGraph image
    * Custom slug
    * RSS date
    * Publish (yes/no)
    * Pinned (yes/no)
  * The item’s body content is then set to the HTML content from the markdown file
* Some of the specific site item classes override the update_from_content method in order to do additional processing: 
  * BlogPost checks for a hero image, contained in an li element with the bold text “Hero Image”
  * Category checks for a comment containing “Category order”, which determines the display order of categories on the site; sets the homepage and overview text; and sets that category’s topic list (with descriptions for each topic)
  * Community updates the featured resources for that community (linked by file path, after a comment containing “Featured resources”)
  * Event sets the event website, location, organizers, and dates from the li objects containing those labels
  * Fellow looks in the HTML for labels for Short Bio, Year, Name, Affiliation, Image, URL, LinkedIn, and Github and fills in each of those fields in the database; it creates associated links for every a element with the class “link-row”; and it sets the fellow’s long bio to the remaining HTML content
  * Page updates the featured posts on the homepage carousel if the path is “Homepage.md”, and updates the bios of staff members if the path is “About.md”
* After all the files have been processed, the rebuild performs some overrides:
  * It visits GitHub to get profile info for each author who has a GitHub website listed
  * It revisits the “About” page for staff info (to make sure that any overrides of GH profile info from there are completed)
  * It revisits the “Contributors.md” page for explicit overrides to contributor profile info
  * It cleans up old rebuilds (deleting all rebuilds except the latest five, and deleting all items with old rebuild ids)
  * It visits all pages, site items, and communities to normalize links and images within the markdown
  * It indexes the search content via the third-party Algolia library, which is initialized in the SearchResult class (all searchable items on the site inherit from SearchResult)
* Once this is complete, the rebuild cleans up after itself and sets the newly-imported items to be displayed:
  * the zipped file from GitHub is deleted
  * the “in progress rebuild” is set to nil
  * the current rebuild’s “end time” is set
  * the “displayed rebuild” is set to the current rebuild.
* If any errors occur during the rebuild process or if the rebuild process is unable to complete for any reason, the site will continue to display the items created during the previous rebuild. The /rebuilds page will indicate which rebuild is currently displayed. This page also has an option to switch the displayed rebuild to another of the 5 most recent rebuilds.