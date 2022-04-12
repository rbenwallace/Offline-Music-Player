COMP4905 Honours Project
Cloud Offline Music Player
Robert Ben Wallace
101070210
Luo Nel
April 25th, 2022

########
Description
########

This application is an IOS music player which allows users to import their own music files from locally or from cloud storage platforms, and allows them to play their songs while online or offline. Users play their songs in a library of all their songs, they can create custom playlists and play songs from within them, they can add songs to a queue, and they are provided a music player view to manipulate the current song playing. Music playing will continue to play in the background, so users can visit other apps while listening to music from this app. There are also many more customization features that can be used in the app which are listed in detail in the "How to Use" section of this readme file. This app also supports accessibility as it is fully functional with all text sizes the user could possibly have on their iPhone. If the user has ever using Apple Music, they will see the user interface inspiration from it and the app aims to provide a similar experience to using that app.

########
Relevant files included
########

- Offline_Music_PlayerApp.swift

This file contains the main function of the app and is the first file run when the app starts up. It task is to add a smart playlist if one does not already exist (important for first launch), it initializes the persistent storage context for the app, and then loads in the ContentView view file.


- ContentView.swift
This file controls the switching between tabs in the app, and there are three tabs. The first tab is Library which contains all of the user's songs downloaded into the app and allows users to import songs from cloud/local storage, add songs to the queue, play songs, and delete songs, The second tab is Playlists which contains all of the user's create playlists plus a smart playlist. If a user clicks a playlist they can add existing songs to the playlist and then it functions similar to the Library tab. The last tab is Queue which stores all the users queued songs and allows the user to manipulate the queue. As well, this view controls the displaying of the player's bar view and full screen view when a song is playing. 


- Assets
Inside the Assets are the images used in the app such as the apps logo, which shows up on the phones home screen, as well as throughout the app in the player views and song/playlist card views.


*** Model Folder ***

- Model.swift
This class is an observable object which is passed throughout views as an environment variable in order to populate views with its @Published variables. These are essential to the views since the @Published annotation alerts the views automatically when its value has changed and renders the view with the changes. In addition, this class controls the audio player, including managing its queue and handling requests to it from various different views to manipulate the audioplayer. 


*** Observer Folder ***

- CurrentSongObserver.swift
This class is an observer for the audio player which monitors changes in the state of the audio player's currentItem attribute (its current song). Every time it changes it publishes that it has changed, which is received by the PlayerView, and then it updates the new current song's plays attribute. 

- TimeObserver.swift
This class is an observer for the audio player which monitors changes in the state of the audio player's currentItem's time attribute (its current song's playback time). Every time it changes it publishes the new time it has changed it, which is received by the PlayerView. 

*** Song Folder ***

- SongCardView.swift
This view class represents a row in the list of displayed songs in either LibraryView, PlaylistSongsView, or SmartSongsView.

*** Library Folder ***

- PlaylistSongsView.swift
This view displays all songs in a given playlist. Here users can play songs, queue songs, add songs to the playlist, and delete songs from the playlist. 

- LibraryView.swift
This view displays all songs imported into the app by the user. Here users can play songs, queue songs, import local/cloud stored songs, and delete songs from the database (including all playlists they are in). 

- SmartSongsView.swift
This view displays all songs in a given smart playlist. Here users can play songs and queue songs, and these playlists are limited to 10 songs automatically chosen by the app based on the smart playlist. 

- QueueView.swift
This view displays all songs the user has queued. Here users can deletee songs from the queue and rearrange the queue however they like. 

*** Playlist Folder ***

- AddPlaylistSongsView.swift
This view displays a list of all songs that are not in a playlist and hence can be added to it, and allows the user to check the songs they do want to add into the playlist

- PlaylistView.swift
This view displays all the smart playlists and custom playlists created by the user. If a user clicks a playlist, they will be brought to PlaylistSongsView. 

- PlaylistCardView.swift
This view class represents a row in the list of displayed playlists in PlaylistsView.

*** Player Folder ***

- PlayerView.swift
This class represents the view of the full screen player display when a song is playing.

- BarPlayerView.swift
This class represents the view of the minimized bar player display when a song is playing.

*** Helper Folder ***

- CustomAlert.swift
This class contains a view that allows a user to input text in a pop up alert. This alert is used for entering a new playlist's title and is used for renaming a song file's title. 

- Helper.swift
This class contains static helper functions that are used throughout various classes in the app. 

*** Storage Folder ***

- Song+CoreDataClass.swift
Manually defined data class for Song entity

- Song+CoreDataProperties.swift
Manually defined data properties class for Song entity, which defines all the entity's attributes as well as the entity's relationship with Playlist entities.

- Playlist+CoreDataClass.swift
Manually defined data class for Playlist entity

- Playlist+CoreDataProperties.swift
Manually defined data properties class for Playlist entity, which defines all the entity's attributes as well as the entity's relationship with Song entities.

- Persistence.swift
This class controls the persistent data storage and management for the app. 

- Database
This stores the Playlist entity and the Song entity, and defines constraints (which entity attributes must be unique) as well as their configurations. 


*** Tests IOS Folder ***
- Tests_AudioPlayer.swift
This file contains all of the unit tests for the main audio player functionalitities.


########
How to run and use the app
########

RUNNING THE APP:

- Open the project in Xcode.

- In the projects Target, under Signing and Capabilities choose a team (your Apple Developer account team).

- Plug an iPhone into your computer and select "Offline Music Player (IOS)" at the top of Xcode beside the run button.

- Click the run button in the top left of Xcode.

- Grant the app permission to open in your iPhones settings app if it fails to run due to untrusted developer, then run it again.


USING THE APP:

*** General usage ***
- On the bottom bar of the app, you will see three tabs which are for Library, Playlists, and Queue.

- When any tab is selected, if a song is playing a bar view will be shown at the bottom of the screen with an image, the title of the currently playing song, and a button to pause/resume the song. If you click on that bar view, a full screen view of the audio player is displayed.

-- In the full screen player view, the user has the options to press previous song, pause/resume, next song, a time bar slider to manipulate the song's current time, -15 seconds, +15 seconds, sleep timer, and a button to go back to the main views. User can also swipe down to escape the full screen view. When the user clicks the sleep timer button they will be given different sleep time options as well as the option to stop the sleep timer. 

*** Inside Library Tab ***
- The user will be presented with a list of all of their songs in order of the time they imported them. 

- To import songs the user must click the + button in the top right corner and use the file importer to choose a song. If the user iPhone has cloud storage platforms set up, they can navigate to them through the file importer and import cloud song files as well. If importing a cloud song file, expect a delay for it to show up as it needs to download into the app's document directory.

- To play a song, the user simply has to click on the song card of the song they want to play. 

- If the user clicks the options icon on the far right side of a song card, they are given two options. They can share the song which will provide a pop up to let the user export the song file elsewhere or they can edit the songs title which will display a pop up and lets the user change the song's title in the database. 

- If the user swipes a song card to the right, it will add that song to the queue, which will be visible in the Queue tab.

- If the user swipes a song card to the left, it will delete the song from all playlists and the database

- If the user clicks the edit button it allows them to delete multiple songs at once from all playlists and the database

*** Inside the Playlists Tab ***
- The user will be presented with all their playlists sorted by least recently added. The first playlist is a smart playlist which takes the users top ten most played songs. Two playlists cannot have the same name, so if you try to make two of the same name the second will get rejected.

- To add a playlist, the user can click the + button and the user will be prompted to enter the playlists name, which then creates the playlist.

- To delete a playlist, 

- To view songs inside a playlist, the user can click the playlist card. 

- Once inside a playlist, to add songs to the playlist, the user can click the + button and they will be prompted to choose from a list of all songs not in the current playlist. When the user has chosen all songs they want to add, they can click the add button and the playlist will be updated with the new songs.

- Once inside a playlist, to play a song, the user can click its song card

- Once inside a playlist, if the user swipes right on a song card it adds the song to the queue, which is visible in the Queue tab.

- Once inside a playlist, if the user swipes left on a song it deletes the song from the playlist

- Once inside a playlist, if the user clicks the edit button they can delete songs from the playlist

*** Inside the Queue Tab ***
- Here the user will see all the currently queued songs (not including the next songs from the playlist/library it was played from) in order such that the song at the top of the list is first item in the queue.

- When the user clicks the edit button in the top right, they have 2 options. They can delete songs from the queue and can also rearrange the order of the songs in the queue.


RUNNING APP TESTS:

- To run the tests for the app, navigate into the "Tests IOS" folder, and then navigate into the Tests_AudioPlayer.swift.
- To the left of line 12, there is an empty diamond which when clicked will run all the tests in the file (make sure a device is plugged into your computer to run the tests on).