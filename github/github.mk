# GitHub integration

.github-init:
	bash github/artifact-init
	touch $@

build/artifact-timestamp:
	touch $@
	sleep 1

build/artifacts{push}: .github-init
	(cd build/artifacts/up; for file in *; do name=$$(basename "$$file"); (cd $(PWD); bash github/ul-artifact "$$name" "build/artifacts/up/$$name"); done)

build/%{artifact}: build/% .github-init
	$(MKDIR) build/artifacts/up
	$(CP) $< build/artifacts/up
	$(MAKE) build/artifacts{push}

build/%{release}: build/% .github-init
	$(MKDIR) build/release
	$(CP) $< build/release

build/github-releases{list}: .github-init | build/github-releases/
	curl -sSL https://api.github.com/repos/$$GITHUB_REPOSITORY/releases?per_page=100 | jq '.[] | [(.).tag_name,(.).id] | .[]' | while read tag; do read id; echo $$id > build/github-releases/$$tag; done
	curl -sSL https://api.github.com/repos/$$GITHUB_REPOSITORY/releases/tags/latest | jq '.[.tag_name,.id] | .[]' | while read tag; do read id; echo $$id > build/github-releases/$$tag; done
	ls -l build/github-releases/

%{release}: .github-init | github/release/
	$(MAKE) build/github-releases{list}
	for name in $$(cd build/release; ls *); do for id in $$(jq ".[] | if .name == \"$$name\" then .id else 0 end" < github/assets/$*.json); do [ $$id != "0" ] && curl -sSL -XDELETE -H "Authorization: token $$GITHUB_TOKEN" "https://api.github.com/repos/$$GITHUB_REPOSITORY/releases/assets/$$id"; echo; done; done
	(for name in build/release/*; do bname=$$(basename "$$name"); curl -sSL -XPOST -H "Authorization: token $$GITHUB_TOKEN" --header "Content-Type: application/octet-stream" "https://uploads.github.com/repos/$$GITHUB_REPOSITORY/releases/$$(cat build/github-releases/\"$*\")/assets?name=$$bname" --upload-file $$name; echo; done)

{release}: .github-init
	this_release_date="$$(date --iso)"; \
	node ./github/release.js $$this_release_date $$this_release_date > github/release.json; \
	curl -sSL -XPOST -H "Authorization: token $$GITHUB_TOKEN" "https://api.github.com/repos/$$GITHUB_REPOSITORY/releases" --data '@github/release.json'; \
	$(MAKE) $$this_release_date{release}
