// See https://aka.ms/new-console-template for more information
using ConsoleApp6.Models;

using (var context = new BarContext())
{
    var lst = context.Beers.ToList();
    foreach (var beer in lst)
    {
        Console.WriteLine(beer.Name);
    }
}
Console.ReadLine();
