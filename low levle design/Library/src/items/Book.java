package items;

public class Book implements LibraryItem {
    
private String title;
private String uniqueId;
private String author;
private double value;

public Book(String title, String uniqueId, String author, double value) {
    this.title = title;
    this.uniqueId = uniqueId;
    this.author = author;
    this.value = value;
}





    @Override
    public String getTitle() {
        return null;
    }

    @Override
    public String getUniqueId() {
        return null;
    }

    @Override
    public int calculateLateFees(int days) {
        return days*10 ;
    }

    @Override
    public double getValue() {
        return this.value;
    }

}
