module DownloadsHelper
  def android_button(version)
    %Q{
      <a href="/downloads/pathfinder-v#{version}.apk" class="btn btn-default btn-sm">
        <i class="fa fa-android"></i> Android აპლიკაცია (v#{version})
      </a>
    }.html_safe
  end
end
