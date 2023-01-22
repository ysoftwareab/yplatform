February 23, 2013Mike Bostock
Why Use Make
I love Make. You may think of Make as merely a tool for building large binaries or libraries (and it is, almost to a fault), but it’s much more than that. Makefiles are machine-readable documentation that make your workflow reproducible.

To clarify, this post isn’t just about GNU Make; it’s about the benefits of capturing workflows via a file-based dependency-tracking build system, including modern alternatives such as Rake and Waf.
To illustrate with a recent example: yesterday Kevin and I needed to update a six-month old graphic on drought to accompany a new article on thin snowpack in the West. The article was already on the homepage, so the clock was ticking to republish with new data as soon as possible.

Shamefully, I hadn’t documented the data-transformation process, and it’s painfully easy to forget details over six months: I had a mess of CSV and GeoJSON data files, but not the exact source URL from the NCDC; I was temporarily confused as to the right Palmer drought metric (Drought Severity Index or Z Index?) and the corresponding categorical thresholds; finally, I had to resurrect the code to calculate drought coverage area.

Despite these challenges, we republished the updated graphic without too much delay. But I was left thinking how much easier it could have been had I simply recorded the process the first time as a makefile. I could have simply typed make in the terminal and be done!

#It’s Files All The Way Down

The beauty of Make is that it’s simply a rigorous way of recording what you’re already doing. It doesn’t fundamentally change how you do something, but it encourages to you record each step in the process, enabling you (and your coworkers) to reproduce the entire process later.

The core concept is that generated files depend on other files. When generated files are missing, or when files they depend on have changed, needed files are re-made using a sequence of commands you specify.

Say you’re building a choropleth map of unemployment and you need a TopoJSON file of U.S. counties. This file depends on cartographic boundaries published by the U.S. Census Bureau, so your workflow might look like:

Download a zip archive from the Census Bureau.
Extract the shapefile from the archive.
Convert the shapefile to TopoJSON.
As a flow chart:

download
extract
convert
counties.zip
counties.shp
counties.json
In a mildly mind-bending maneuver, Make encourages you to express your workflow backwards as dependencies between files, rather than forwards as a sequential recipe. For example, the shapefile depends on the zip archive because you must download the archive before you can extract the shapefile (obviously). So to express your workflow in language that Make understands, consider instead the dependency graph:

depends on
depends on
counties.json
counties.shp
counties.zip
This way of thinking can be uncomfortable at first, but it has advantages. Unlike a linear script, a dependency graph is flexible and modular; for example, you can augment the makefile to derive multiple shapefiles from the same zip archive without repeated downloads. Capturing dependencies also begets efficiency: you can remake generated files with only minimal effort when anything changes. A well-designed makefile allows you to iterate quickly while keeping generated files consistent and up-to-date.

#The Syntax Isn’t Pretty

The ugly side of Make is its syntax and complexity; the full manual is a whopping 183 pages. Fortunately, you can ignore most of this, and start with explicit rules of the following form:

targetfile: sourcefile
	command
Here targetfile is the file you want to generate, sourcefile is the file it depends on (is derived from), and command is something you run on the terminal to generate the target file. These terms generalize: a source file can itself be a generated file, in turn dependent on other source files; there can be multiple source files, or zero source files; and a command can be a sequence of commands or a complex script that you invoke. In Make parlance, source files are referred to as prerequisites, while target files are simply targets.

Here’s the rule to download the zip archive from the Census Bureau:

counties.zip:
	curl -o counties.zip 'http://www2.census.gov/geo/tiger/GENZ2010/gz_2010_us_050_00_20m.zip'
Put this code in a file called Makefile, and then run make from the same directory. (Note: use tabs rather than spaces to indent the commands in your makefile. Otherwise Make will crash with a cryptic error.) If it worked, you should see a downloaded counties.zip in the directory.

You can approximate URL dependencies by checking the Last-Modified header via curl -I.
This first rule has no dependencies because it’s the first step in the workflow, or equivalently a leaf node in the dependency graph. Although the zip file depends on the Census Bureau’s website, and thus can change, Make has no native facility for checking if the contents of a URL have changed, and thus a makefile cannot specify a URL as a prerequisite. As a result, the counties.zip file will only be downloaded if it does not yet exist. If the Census Bureau releases new cartographic boundaries, you’ll need to delete the previously-downloaded zip file before running make.

The second rule for creating the shapefile now has a prerequisite: the zip archive.

I preserved the Census Bureau’s original verbose file name (gz_2010_us_050_00_20m). You could instead rename files using parameter expansion.
gz_2010_us_050_00_20m.shp: counties.zip
	unzip counties.zip
	touch gz_2010_us_050_00_20m.shp
This rule also has two commands. First, unzip expands the zip archive, producing the desired shapefile and its related files. Second, touch sets the modification date of the shapefile to the current time.

The final touch is critical to Make’s understanding of the dependency graph. Without it, the modification time of the shapefile will be when it was created by the Census Bureau, rather than when it was extracted. Since the shapefile is apparently older than the zip archive from which it was extracted, Make thinks it needs to be rebuilt—even though it was just made! Fortunately, most programs set the modification dates of their output files to the current time, so you’ll probably only need touch when using unzip.

Lastly to convert to TopoJSON, a rule with one command and one prerequisite:

counties.json: gz_2010_us_050_00_20m.shp
	topojson -o counties.json -- counties=gz_2010_us_050_00_20m.shp
With these three rules together in a makefile (which you can download), make counties.json will perform the necessary steps to produce a U.S. Counties TopoJSON file from scratch.

You can get a lot fancier with your makefiles; for example, pattern rules and automatic variables are useful for generic rules that generate multiple files. But even without these fancy features, hopefully you now have a sense of how Make can capture file-based workflows.

#You Should Use Make

Created in 1977, Make has its quirks. But whether you prefer GNU Make or a more recent alternative, consider the benefits of capturing your workflow in a machine-readable format:

Update any source file, and any dependent files are regenerated with minimal effort. Keep your generated files consistent and up-to-date without memorizing and running your entire workflow by hand. Let the computer work for you!

Modify any step in the workflow by editing the makefile, and regenerate files with minimal effort. The modular nature of makefiles means that each rule is (typically) self-contained. When starting new projects, recycle rules from earlier projects with a similar workflow.

Makefiles are testable. Even if you’re taking rigorous notes on how you built something, chances are a makefile is more reliable. A makefile won’t run if it’s missing a step; delete your generated files and rebuild from scratch to test. You can then be confident that you’ve fully captured your workflow.

To see more real-world examples of makefiles, see my World Atlas and U.S. Atlas projects, which contain makefiles for generating TopoJSON from Natural Earth, the National Atlas, the Census Bureau, and other sources. The beauty of the makefile approach is that I don’t need gigabytes of source data in my git repositories (Make will download them as needed), and the makefile is infinitely more customizable than pre-generating a fixed set of files. If you want to customize how the files are generated, or even just use the makefile to learn by example, it’s all there.

So do your future self and coworkers a favor, and use Make!