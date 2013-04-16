
schema "0.0.1" do

  entity "Article" do

    string    :body,        optional: false
    integer32 :length
    boolean   :published,   default: false
    datetime  :publishedAt, default: false
    string    :title,       optional: false

    #has_one   :author
  end

  entity "Author" do
    string :name, optional: false
    float :fee
    #has_many :articles 
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
        <relationship name="author" optional="YES" minCount="1" maxCount="1" deletionRule="Nullify" destinationEntity="Author" inverseName="articles" inverseEntity="Author" syncable="YES"/>
    </entity>
    <entity name="Author" syncable="YES">
        <attribute name="fee" optional="YES" attributeType="Float" defaultValueString="0.0" syncable="YES"/>
        <attribute name="name" optional="YES" attributeType="String" syncable="YES"/>
        <relationship name="articles" optional="YES" minCount="1" maxCount="1" deletionRule="Nullify" destinationEntity="Article" inverseName="author" inverseEntity="Article" syncable="YES"/>
    </entity>
    <elements>
        <element name="Author" positionX="160" positionY="192" width="128" height="90"/>
        <element name="Article" positionX="160" positionY="192" width="128" height="135"/>
    </elements>
</model>
