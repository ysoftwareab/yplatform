# useful internally as
# some-target-that-should-run-minimum-once-per-hour: $(SENTINEL_ONCE_PER_HOUR)

SENTINEL_PREFIX = Makefile.sentinel
SENTINEL_ONCE_PER_MINUTE = $(SENTINEL_PREFIX).minute.$(shell date +"%Y-%m-%d-%H-%M")
SENTINEL_ONCE_PER_HOUR = $(SENTINEL_PREFIX).hour.$(shell date +"%Y-%m-%d-%H")
SENTINEL_ONCE_PER_DAY = $(SENTINEL_PREFIX).day.$(shell date +"%Y-%m-%d")
SENTINEL_ONCE_PER_WEEK = $(SENTINEL_PREFIX).week.$(shell date +"%Y.week-%V")
SENTINEL_ONCE_PER_MONTH = $(SENTINEL_PREFIX).month.$(shell date +"%Y-%m")

# ------------------------------------------------------------------------------

$(SENTINEL_ONCE_PER_MINUTE):
	$(RM) $(SENTINEL_PREFIX).minute.*
	$(TOUCH) $@

$(SENTINEL_ONCE_PER_HOUR):
	$(RM) $(SENTINEL_PREFIX).hour.*
	$(TOUCH) $@

$(SENTINEL_ONCE_PER_DAY):
	$(RM) $(SENTINEL_PREFIX).day.*
	$(TOUCH) $@

$(SENTINEL_ONCE_PER_WEEK):
	$(RM) $(SENTINEL_PREFIX).week.*
	$(TOUCH) $@

$(SENTINEL_ONCE_PER_MONTH):
	$(RM) $(SENTINEL_PREFIX).month.*
	$(TOUCH) $@
