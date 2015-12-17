module DownloadsHelper
  def android_button
    version = Pathfinder::LATEST_APK_VERSION
    %Q{
      <a href="/downloads/pathfinder-v#{
      version}.apk" class="btn btn-default btn-sm">
        <i class="fa fa-android"></i> Android აპლიკაცია (v#{version})
      </a>
      <a href="/downloads/app-debug.apk" class="btn btn-default btn-sm">
        <i class="fa fa-android"></i> Android აპლიკაცია satesto (v#{version})
      </a>
    }.html_safe
  end
end
