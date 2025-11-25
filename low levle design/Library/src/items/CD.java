package items;

public class CD implements LibraryItem {
    String title;
    public String uniqueId;
    private String artist;
    private double value;

    public CD(String title, String uniqueId, String artist, double value) {
        this.title = title;
        this.uniqueId = uniqueId;
        this.artist = artist;
        this.value = value;
    }

    @Override
    public String getTitle() {
        return this.title;
    }

    @Override
    public String getUniqueId() {
        return this.uniqueId;
    }

    @Override
    public int calculateLateFees(int days) {
        return days * 5;
    }

    @Override
    public double getValue() {
        return this.value;
    }

}
