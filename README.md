# WeatherWatch
Plugin for [MCServer](http://mc-server.org) that monitors weather and creates statistics

# What it does
The plugin logs each and every weather change in any of the worlds that the server has loaded, to a logfile `weather.log`. Also, when unloaded (during server shutdown or plugin reload), the plugin writes a summary statistics to the logfile.

Example output:
```
World "world": weather changing from sunny to rain after 163 ticks.
World "world": weather changing from rain to storm after 110 ticks.
World "world": weather changing from storm to sunny after 125 ticks.
World "world": weather changing from sunny to storm after 91 ticks.
World "world": weather changing from storm to sunny after 73 ticks.
	Statistics for world "world":
		sunny has been active for 255 ticks (45.29 %)
		It has become sunny 3 times and the average length was 85 ticks.
		The weather has then transitioned to sunny 1 times, rainy 1 times and storm 1 times
		rain has been active for 110 ticks (19.54 %)
		It has become rain 1 times and the average length was 110 ticks.
		The weather has then transitioned to sunny 0 times, rainy 0 times and storm 1 times
		storm has been active for 198 ticks (35.17 %)
		It has become storm 2 times and the average length was 99 ticks.
		The weather has then transitioned to sunny 2 times, rainy 0 times and storm 0 times
```

# Installation
Installing this plugin is done the same as with any other MCServer plugin - download the ZIP and extract into `Plugins` subfolder. Alternatively, you can git-clone the plugin to the proper place.
Then, enable the plugin in the `settings.ini` file or via MCServer's webadmin.
