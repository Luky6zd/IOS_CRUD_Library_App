//
//  BookList.swift
//  MyBooks
//
//  Created by Lucrezia Odrljin on 06.07.2024.


import SwiftUI
import SwiftData

struct BookList: View {
    // environment property sa putanjom ključa od modela knjige u bazi
    // pristup contexu u bazi podataka za brisanje knjiga
    @Environment(\.modelContext) private var context
    // query property za izbor sortiranja knjiga
    // omotac, pomocu njega citamo podatke iz baze podataka, sortira knjige po autoru
    // staticki key path
    //@Query(sort: \Book.author) private var books: [Book]
    
    // kreiranje dinamickog sortiranja
    @Query private var books: [Book]
    
    // initializer za View
    // initu prosljedujemo argument sort order tipa Enum SortOrder
    init(sortOrder: SortOrder) {
        // property tipa array generics, sortiranje po Book modelu
        // switchamo kroz enum Sort Order po autoru, naslovu i statusu
        let sortDescriptor: [SortDescriptor<Book>] = switch sortOrder {
        // sort po autoru
        case .author:
            [SortDescriptor(\Book.author)]
        // sort po naslovu
        case .title:
            [SortDescriptor(\Book.title)]
        // sort po statusu
        case .status:
            [SortDescriptor(\Book.status), SortDescriptor(\Book.title)]
        }
        // update query
        _books = Query(sort: sortDescriptor)
    }
    
    
    var body: some View {
        // grupiranje arraya knjiga da se toolbar i naslov mogu uvijek prikazivati na ekranu,
        // bez obzira na if
        Group {
            // ako je array liste knjiga prazan
            if books.isEmpty {
                // ako je, prikazuje tekst i simbol na ekranu
                ContentUnavailableView("Enter your first book", systemImage: "book.fill")
                // ako lista nije prazna
            } else {
                // kreiranje/prikaz List View knjiga
                List {
                    // petlja prolazi kroz sve knjige
                    ForEach(books) { book in
                        // kreiranje Viewa koji prikazuje detalje o knjizi, s mogucnoscu
                        // prikaza i editiranja
                        NavigationLink {
                            // pozivanje komponente
                            EditBookView(book: book)
                        // oznaka za ikonice
                        } label: {
                            // formirane u horizontalni stack
                             HStack(spacing: 10) {
                                // prvi element u stacku
                                book.icon
                                // vertikalni stack, poravnavanje s lijeve strane
                                VStack(alignment: .leading) {
                                    // 1.red prikaz naslova
                                    Text(book.title).font(.title2)
                                    // 2.red prikaz autora
                                    Text(book.author).foregroundStyle(.secondary)
                                    // kreiranje zvjezdica(book ratinga)
                                    if let rating = book.rating {
                                        // ako postoji, kreiraj horizontalni stack
                                        HStack {
                                            // petlja prolazi od 1 do vrijednosti ratinga
                                            ForEach(1..<rating, id: \.self) {
                                                _ in
                                                // i za svaku knjigu kreira broj zvjezdica
                                                Image(systemName: "star.fill")
                                                    // View Modifieri
                                                    .imageScale(.small)
                                                    .foregroundStyle(.yellow)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // funkcija za brisanje knjiga(swipe u lijevo)
                    // po indexSetu swipe-amo
                    .onDelete { indexSet in
                        // petlja po indexu prolazi kroz array knjiga
                        indexSet.forEach { index in
                            let book = books[index]
                            // brise odabranu knjigu
                            context.delete(book)
                        }
                    }
                }
                // stil liste
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    // kreiranje custom preview containera sa @Modelom book
    let preview = PreviewContainer(Book.self)
    // u preview (container) spremamo primjere knjiga sto ih funkcija vrati
    preview.addExamples(Book.sampleBooks)
    // preview vraca Navigation stack View sa listom knjiga
    return NavigationStack {
        // odabrani sort order je autor
        BookList(sortOrder: .author)
    }
        // pozivanje funkcije za prikaz knjiga iz preview containera
        .modelContainer(preview.container)
}
