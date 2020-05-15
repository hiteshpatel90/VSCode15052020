trigger trgAccountTracking on Account (after update) { 
    fieldTrackingHandler.handleFieldTracking();
}