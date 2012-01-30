ifeq ($(origin JAVA_HOME), undefined)
  JAVA_HOME=/usr
endif

ifeq ($(origin NETLOGO), undefined)
  NETLOGO=../..
endif

JAVAC=$(JAVA_HOME)/bin/javac
SRCS=$(wildcard src/*.java)

sound.jar: $(SRCS) manifest.txt Makefile
	mkdir -p classes
	$(JAVAC) -g -deprecation -Xlint:all -Xlint:-serial -Xlint:-path -encoding us-ascii -source 1.5 -target 1.5 -classpath $(NETLOGO)/NetLogoLite.jar -d classes $(SRCS)
	jar cmf manifest.txt sound.jar -C classes .

sound.zip: sound.jar
	rm -rf sound
	mkdir sound
	cp -rp sound.jar README.md Makefile src manifest.txt soundbank-min.gm sound
	zip -rv sound.zip sound
	rm -rf sound
