
schema "0.0.1" do

  entity "Article" do

    user_info_entry 'userinfotest', 'userinfovalue'
    string    :body,        optional: false
    integer32 :length
    boolean   :published,   default: false
    datetime  :publishedAt, default: false
    string    :title,       optional: false

    belongs_to   :author
  end

  entity "Author" do
    float :fee
    string :name, optional: false
    has_many :articles
  end

end


__END__

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model name="" userDefinedModelVersionIdentifier="0.0.1" type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0" lastSavedToolsVersion="2061" systemVersion="12D78" minimumToolsVersion="Xcode 4.3" macOSVersion="Automatic" iOSVersion="Automatic">
    <entity name="Article" syncable="YES">
        <attribute name="body" optional="YES" attributeType="String" syncable="YES"/>
        <attribute name="length" optional="YES" attributeType="Integer 32" defaultValueString="0" syncable="YES"/>
        <attribute name="published" optional="YES" attributeType="Boolean" syncable="YES"/>
        <attribute name="publishedAt" optional="YES" attributeType="Date" syncable="YES"/>
        <attribute name="title" optional="YES" attributeType="String" syncable="YES"/>
        <relationship name="author" optional="YES" minCount="1" maxCount="1" deletionRule="Nullify" destinationEntity="Author" inverseName="articles" inverseEntity="Article" syncable="YES"/>
        <userInfo>
            <entry key="userinfotest" value="userinfovalue"/>
        </userInfo>
    </entity>
    <entity name="Author" syncable="YES">
        <attribute name="fee" optional="YES" attributeType="Float" defaultValueString="0.0" syncable="YES"/>
        <attribute name="name" optional="YES" attributeType="String" syncable="YES"/>
        <relationship name="articles" optional="YES" minCount="1" maxCount="1" deletionRule="Nullify" destinationEntity="Article" inverseName="author" inverseEntity="Author" syncable="YES"/>
    </entity>
</model>
