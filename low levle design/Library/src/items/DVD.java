package items;

public class DVD implements LibraryItem{
    private String title;
    private String director;
    private String uniqueId;
    private int playingTime;
    private double value;

    public DVD(String title,String uniqueId, String director, int playingTime,double value) {
        this.title = title;
        this.director = director;
        this.playingTime = playingTime;
        this.uniqueId = uniqueId;
        this.value = value;
    }

    @Override
    public String getTitle() {
        return title;
    }

    @Override
    public String getUniqueId() {
        return this.uniqueId;
    }

    @Override
    public int calculateLateFees(int days){
        return 25*days;
    }

    @Override
    public double getValue(){
        return this.value;
    }

    public int getPlayingTime() {
        return playingTime;
    }
    
    public void borrow() {
        System.out.println("DVD '" + title + "' by " + director + " has been borrowed.");
    }

    public void returnItem() {
        System.out.println("DVD '" + title + "' by " + director + " has been returned.");
    }

}
