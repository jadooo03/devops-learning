package items;

public interface LibraryItem {

    String getTitle();

    String getUniqueId();

    int calculateLateFees(int days);

    double getValue();
}
