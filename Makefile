all:
	$(MAKE) clean
	$(MAKE) app
	$(MAKE) ipa


clean:
	rm -rf build
	rm -rf Products

  # Legacy - can be safely removed at some point
	rm -rf Calabash-app
	rm -rf Calabash-ipa

# Builds an ipa linked with the Calabash server.
#
# Respects the CODE_SIGN_IDENTITY variable, which might be necessary
# if you have multiple Developer accounts.
# $ CODE_SIGN_IDENTITY="iPhone Developer: Joshua Moody (8<snip>F)" make ipa
ipa:
	bin/make/ipa.sh

# Builds an app linked with the Calabash server.
app:
	bin/make/app.sh

tags:
	bin/make/vim-ctags.sh

