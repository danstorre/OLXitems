# OLXitems
simple app that consumes an olx service for retrieving items in the www.olx.com.ar domain.

# Config
Git clone https://github.com/danstorre/OLXitems.git <br />
go to the project’s folder and run <br />
<br />
	**carthage bootstrap --platform iOS --no-use-binaries** <br />

run the app.<br />

# Architecture

MVVM used <br />
viewmodels and viewcontrollers are 1:1 relation. <br />
ItemsManager is used to consume the services needed. <br />
the project uses react swift (RxSwift) but not entirely this way. <br />

# Features

###### autocompletion for searching items<br />
###### pull to refresh<br />
###### cache of images once the item is hit<br />
###### autolayout<br />
###### pagination<br />
###### reachability<br />

# Tested on
Tested on Xcode Version 8.3.2 (8E2002)

