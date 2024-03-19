//Matrice della Strategia
public with sharing class vStrategia
{
    public String vCampo { get; set; }
    public String vStrat { get; set; }
    public String vCondizione { get; set; }
    public String vReale { get; set; }
    public String vIngresso { get; set; }
    public Boolean bControl { get; set; }
    
    // ES: 17/02/2015
    public vStrategia(String vCampo, String vStrat, String vCondizione, String vReale, String vIngresso, Boolean bControl)
    {
        this.vCampo = vCampo;
        this.vStrat = vStrat;
        this.vCondizione = vCondizione;
        this.vReale = vReale;
        this.vIngresso = vIngresso;
        this.bControl = bControl;
    }
    public vStrategia(String vCampo, String vStrat, String vIngresso, String vReale)
    {
        this.vCampo = vCampo;
        this.vStrat = vStrat;
        this.vReale = vReale;
        this.vIngresso = vIngresso;        
    }
    
    public vStrategia(String vCampo, String vStrat, String vReale, Boolean bControl)
    {
        this.vCampo = vCampo;
        this.vStrat = vStrat;
        this.vReale = vReale;
        this.bControl = bControl;
    }
    
    public vStrategia(String vCampo, String vStrat, String vReale, String vIngresso, Boolean bControl)
    {
        this.vCampo = vCampo;
        this.vStrat = vStrat;
        this.vReale = vReale;
        this.vIngresso = vIngresso;
        this.bControl = bControl;
    }
}