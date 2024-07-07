import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // firebase service object
  final FirestoreService firestoreService=FirestoreService();

  //text controller
  final TextEditingController textController=TextEditingController();


  // open a dilogue box to add note
  void openNoteBox({String? docID}){
    showDialog(context: context, builder: (context)=>AlertDialog(content: TextField(
      controller: textController,
    ),actions: [
      //button to save 
      ElevatedButton(
        onPressed: (){
          //add a new node
          if (docID== null) {
            firestoreService.addNote(textController.text);
          }
          // update existing note
          else{
              firestoreService.updateNote(docID, textController.text);
          }

          //cleare text field
          textController.clear();

          //close the box
          Navigator.pop(context);
        },
        child: Text("Add"))
    ],
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Center(child: Text("Notes",style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold,fontSize: 25),),),backgroundColor: Color.fromARGB(255, 0, 0, 0),),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        
        onPressed: openNoteBox,
        child: const Icon(Icons.add,color: Color.fromARGB(255, 255, 255, 255),size: 40,),
        ),
      body: StreamBuilder<QuerySnapshot>(stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        // if we have data then get all docs
      
        if(snapshot.hasData){
          List notesList=snapshot.data!.docs;

          // display as a list
          return ClayContainer(
            color: Colors.white,
            child: ListView.builder(
              itemCount: notesList.length ,
              itemBuilder: (context, index) {
            
                // get each indivisual docs
                DocumentSnapshot document=notesList[index];
                String docID=document.id;
            
                // get notes from each docs
                Map<String,dynamic> data=document.data() as Map<String,dynamic>;
                String noteText=data['note'];
            
            
                //display as a list title
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: ClayContainer(
                    borderRadius: 5,
                    child: ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //update button
                          IconButton(onPressed: () =>openNoteBox(docID:docID ),
                      icon: const Icon(Icons.edit,color: Colors.black),
                                
                      ),
                                
                                
                      // delete button 
                      IconButton(onPressed: () =>firestoreService.deleteNote(docID ),
                      icon: const Icon(Icons.delete,color: Colors.black),
                      ),
                                
                     
                      
                        ],
                      )
                    ),
                  ),
                );
            
              },
            
            ),
          );
        }else{
          return const Text("No notes...");
        }
      } ,),
    );
  }
}