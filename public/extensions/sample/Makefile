ifeq ($(origin JAVA_HOME), undefined)
  JAVA_HOME=/usr
endif

ifeq ($(origin NETLOGO), undefined)
  NETLOGO=../..
endif

JAVAC=$(JAVA_HOME)/bin/javac
SRCS=$(wildcard src/*.java)

sample.jar: $(SRCS) manifest.txt Makefile $(JARS)
	mkdir -p classes
	$(JAVAC) -g -deprecation -Xlint:all -Xlint:-serial -Xlint:-path -encoding us-ascii -source 1.5 -target 1.5 -classpath $(NETLOGO)/NetLogoLite.jar:$(JARSPATH) -d classes $(SRCS)
	jar cmf manifest.txt sample.jar -C classes .

sample.zip: sample.jar
	rm -rf sample
	mkdir sample
	cp -rp sample.jar README.md Makefile src manifest.txt sample
	zip -rv sample.zip sample
	rm -rf sample
